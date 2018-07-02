# What is this?

This is a simple wrapper for `git status` written in bash.

# Why this?

I am constantly working with a large number of git repositories, and I find it to be very tedious to have to look at
each of them individually to keep them up to date.

# What does it do?

You can

- `register` as many repositories as you want. The paths to them are simply stored in and retreived from a file.

- then use `status` to get the status for each repository (See example [1]). (Fetche remote + status)

- get a `list` of the registered repositories.

- `remove` a repository from the list (or simply edit the file storing them).

- `go` to the repository in a new terminal (set up to work with urxvt).

```
got (-r | register) [-p <PATH>]   registers repo
got (-s | status) [-c] [-q]       [--quiet] status for registered repos [--control]
got (-l | list)                   list registered repos
got remove [<NUMBER>]             remove registration
got go [<NUMBER>]                 open repo in new terminal
```

# Show me some examples

Ok:

[0] register 
```
omni@base:~$ got -r --path=/home/omni/repos/got
Found /home/omni/repos/got/.git
Adding to tracked repos...
```

[1] status
```
omni@base:~$ got -s
==================================================

[ /home/omni ] (0)
( omni ):

Fetching origin

On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean

==================================================

[ /home/omni/repos/got ] (1)
( got ):

Fetching origin

On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   test_file


==================================================
Report:
""""""
[1] /home/omni/repos/got:
    new file:   test_file

```

[2] quiet status
```
omni@base:~$ got -s -q
==================================================
Report:
""""""
[1] /home/omni/repos/got:
    new file:   test_file

```

# Note

this might not work for you, but feel free to expand on it.
