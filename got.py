#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# port of got.sh so it works on non sh shells
# (without me needing to bother with portable sh code)

import sys
import os
from typing import Callable

registration_path=os.path.expanduser("~/.config/got")
registration_file="repos.greg"
registration_location=os.path.join(registration_path, registration_file) 

def print_usage():
	print('got (-r | register) [-p <PATH>]   registers repo')
	print('got (-s | status)                 status for registered repos')
	print('got (-l | list)                   list registered repos')

def error(msg: str):
    print("ERR: " + msg)
    sys.exit(1)

# returns true if registry already existed
# returns false if a new one was created
# exits program if none exists and none created
def check_registry() -> bool:
    if (not os.path.isfile(registration_location)):
        print("Registration file does not exist yet")
        response = input("Create under {p}? [y/n]".format(p=registration_location))
        if (response not in ["y", "Y"]):
            print("Not creating... Exit")
            sys.exit(0)
        print("Creating now...")
        os.makedirs(os.path.dirname(registration_location), exist_ok=True)
        with open(registration_location, "w") as f:
            f.write("# /path/to/repo")
        return False
    return True


def do_for_each_repo(func: Callable[[int, str], None]) -> None:
    with open(registration_location, "r") as f:
        i = 0
        for line in f.readlines():
            _line = line.strip()
            if (_line.startswith("#")):
                continue
            func(i, _line)
            i += 1



# dirty but just have a glob here and fill in status_for_repo
# keeps do_for_each_repo simpler
_status_collect = {}

# checks git status, prints to stdout and returns a short change description
def status_for_repo(i: int, path: str) -> None:
    print("------------------------------------------")
    print("[{i}] - {p}".format(i=i, p=path))
    print("")

    if (not os.path.isdir(path)):
        print("No such directory!")
        return
    if (not os.path.isdir(os.path.join(path, ".git"))):
        print("Not a git repository!")
        return

    # visible output for user
    os.system("git -C {p} remote update".format(p=path))
    os.system('git -C {p} status | GREP_COLOR=\'30;47\' grep --color=always -E "up to date|up-to-date|ahead|behind|diverged|$" | GREP_COLOR=\'30;47\' grep --color=always -E "by [0-9]+ commit[s]*|$" | GREP_COLOR=\'39;4\' grep --color=always -E "modified:|deleted:|new file:|renamed:|$"'.format(p=path))

    # store the change without printing
    change = os.popen("git -C {p} status | grep -E 'ahead|behind|modified|diverged|deleted|renamed|new file'".format(p=path)).read()
    _lines = [l.strip() for l in change.split("\n")]
    _status_collect[i] = [path, *_lines]
    

def main():
    args = sys.argv[1:]

    if not args:
        print_usage()
        sys.exit(1)

    elif args[0] in ["-h", "--help"]:
        print_usage()
        sys.exit(0)

    elif args[0] in ["-l", "list"]:
        if (not check_registry()):
            sys.exit(0)

        do_for_each_repo(
            lambda i,line: print("[{i}] {l}".format(i=str(i), l=line))
        )
                
        sys.exit(0)

    elif args[0] in ["-r", "register"]:
        repo_path: str = os.getcwd()

        if (len(args) > 1 and args[1] == "-p"):
            if (len(args) > 2):
                repo_path = args[2]
            else:
                error("expected path after -p")

        if (not os.path.isdir(repo_path)):
            error("Not a directory: {p}".format(p=repo_path))
            
        if (not os.path.isdir(os.path.join(repo_path, ".git"))):
            error("Not a git repo: {p}".format(p=repo_path))

        print("Found valid git repository under {p}".format(p=repo_path))

        check_registry()
        
        print("Adding to registry under {p}".format(p=registration_location))
        with open(registration_location, "a") as f:
            f.write(repo_path + "\n")

        print("Done")
        sys.exit(0)

    elif args[0] in ["-s", "status"]:
        if (not check_registry()):
            sys.exit(0)

        do_for_each_repo(status_for_repo)

        if _status_collect:
            print("===========================")
            for index in _status_collect:
                _lines = _status_collect[index]
                print("[{i}] - {p}".format(i=index, p=_lines[0]))
                for line in _lines[1:]:
                    print("   " + line)

        sys.exit(0)

    print_usage()
    sys.exit(1)

    




if __name__ == '__main__':
    main()

