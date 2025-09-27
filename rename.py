import os
import re

def list_directory(path_to_dir):
    listdir = os.listdir(path_to_dir)
    for row in listdir:
        curdir = os.path.join(path_to_dir, row)
        if os.path.isdir(curdir):
            list_directory(curdir)
            rename(curdir)
        else:
            rename(curdir)

def rename(path):
    dir_path = ''.join(os.path.split(path)[:-1])
    result = re.compile("^.*]\s").match(os.path.basename(path))
    if result is not None:
        string = result.group(0)
        old_name = os.path.join(dir_path, os.path.basename(path))
        new_name = os.path.join(dir_path, os.path.basename(path).replace(string, ''))
        os.rename(old_name, new_name)
        print(os.path.abspath(new_name))


if __name__ == "__main__":
    list_directory(os.path.abspath("."))