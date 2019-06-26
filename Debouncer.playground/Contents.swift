import Cocoa

public struct DispatchSemaphoreWrapper {
    private let semphore: DispatchSemaphore
    
    public init(withValue value: Int) {
        self.semphore = DispatchSemaphore(value: value)
    }
    
    public func sync<R>(execute: () throws -> R) rethrows -> R {
        _ = semphore.wait(timeout: DispatchTime.distantFuture)
        defer { semphore.signal() }
        return try execute()
    }
}

class Debouncer {
    public let label: String
    public let interval: DispatchTimeInterval
    fileprivate let queue: DispatchQueue
    fileprivate let semaphore: DispatchSemaphoreWrapper
    fileprivate var workItem: DispatchWorkItem?
    
    public init(label: String, interval: Float, qos: DispatchQoS = .userInteractive) {
        self.interval = .milliseconds(Int(interval * 1000))
        self.label = label
        self.queue = DispatchQueue(label: "com.farfetch.debouncer.internalqueue.\(label)", qos: qos)
        self.semaphore = DispatchSemaphoreWrapper(withValue: 1)
    }
    
    public func call(_ callback: @escaping(() -> ())) {
        self.semaphore.sync { () -> () in
            self.workItem?.cancel()
            self.workItem = DispatchWorkItem {
                callback()
            }
            if let workItem = self.workItem {
                self.queue.asyncAfter(deadline: .now() + self.interval, execute: workItem)
            }
        }
    }
}

public class Throttler {
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private var maxInterval: Int
    
    init(seconds: Int) {
        self.maxInterval = seconds
    }
    
    func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem() { [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date.second(from: previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}

private extension Date {
    static func second(from referenceDate: Date) -> Int {
        return Int(Date().timeIntervalSince(referenceDate).rounded())
    }
}


