# -*- coding:utf-8 -*-

import sys
import os


def renameFilesOfDir(dir):
    for file in os.listdir(dir):
        if os.path.isfile(os.path.join(dir, file)) is True:
            main_name, extern_name = os.path.splitext(file)
            if extern_name == ".null":
                newName = main_name + ".mp4"
                os.rename(os.path.join(dir, file), os.path.join(dir, newName))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("请指定路径")
        exit(0)

    target_dir = sys.argv[1]
    if not os.path.isdir(target_dir) or not os.path.exists(target_dir):
        print("请指定正确的路径")
        exit(0)

    renameFilesOfDir(target_dir)
