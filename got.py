#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os

registration_path=os.path.expanduser("~/.config/got")
registration_file="repos.greg"
registration_location=os.path.join(registration_path, registration_file) 

def print_usage():
	print('got (-r | register) [-p <PATH>]   registers repo')
	print('got (-s | status) [-c] [-q]       [--quiet] status for registered repos [--control]')
	print('got (-l | list)                   list registered repos')
	print('got remove [<NUMBER>]             remove registration')
	print('got go [<NUMBER>]                 open repo in new terminal')

def error(msg: str):
    print("ERR: " + msg)
    sys.exit(1)


def main():
    args = sys.argv[1:]

    if not args:
        print_usage()
        sys.exit(1)

    if args[0] in ["-h", "--help"]:
        print_usage()
        sys.exit(0)

    if args[0] in ["-r", "register"]:
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
        
        print("Adding to registry under {p}".format(p=registration_location))
        with open(registration_location, "a") as f:
            f.write(repo_path + "\n")

        print("Done")
        sys.exit(0)

    if args[0] in ["-s", "status"]:
        sys.exit(0)

    if args[0] in ["-l", "list"]:
        sys.exit(0)

    if args[0] == "remove":
        sys.exit(0)

    if args[0] == "go":
        sys.exit(0)

    




if __name__ == '__main__':
    main()

