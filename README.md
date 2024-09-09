# Yona

*The script that stands in the blush of the build*
This is Yona, shell script (originally powershell, now bash) that has 
ballooned into a mini-application. Its goals are twofold:

1. To make it simple to get "code running" functionality in any code editor 
   with access to a terminal emulator.
2. To make running project level commands (your testing, build script, etc.) 
   from *anywhere* inside your project, not just the top level directory - 
   which we call *project root*.

It does (1) by taking the path to a file, figuring out its file type, and 
then passing the relevant arguments to the relevant software to compile 
and/or run it.

It does (2) by taking a word - a *project command* - looking for a file in 
which this command is defined, and running the command in the directory 
where the file was.

## Getting Started

Yona is written in bash version 5.2. It is not guaranteed to work on older 
versions of bash. It also requires `cut` (a GNU coreutil).

So, all in all, yona should work on most Linux systems.

## Usage

```bash
yona PROJECT_COMMAND
yona [-l|--list] [DIRECTORY]
yona [-f|--file] [run|compile] FILE
yona [-s|--shell] SHELL_COMMAND
ysh SHELL_COMMAND
```


