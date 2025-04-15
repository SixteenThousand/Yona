# Yona

*The script that stands in the blush of the build*

This is Yona, shell script (originally PowerShell, now bash) that has 
ballooned into a mini-application. Its goals are twofold:

1. To make it simple to get "code running" functionality in any code editor 
   with access to a terminal emulator.
2. To make it possible to run project level commands (your testing, build 
   script, etc.) from *anywhere* inside your project, not just the top level 
   directory (which we call *project root* here).

It does (1) by taking the path to a file, figuring out its file type, and 
then passing the relevant arguments to the relevant software to compile 
and/or run it.

It does (2) by taking a word - a *project command* - looking for a file in 
which this command is defined, and running the command in the directory 
where the file was.


## Getting Started

Yona is written in bash, version 5.2. It is not guaranteed to work with 
older versions of bash. It also relies on other utilities, although all 
utilities used should be common to any vaguely POSIX compliant OS.
Currently the used utilities are:
    - sed
    - less
    - wc
    - xargs
    - find
    - grep
    - m4 (only needed for building)
    - realpath

To install Yona, clone this repository and run `make build`. This will 
combine all the bash scripts here into one, executable, script that you can 
then just place anywhere on your `$PATH` to use. An `install` recipe is 
provided, but the directory it uses is not guaranteed to be on your `$PATH`.


## Configuration

Yona is not configured; the only way to change its behaviour is to alter the 
source code and rebuild. That being said, the project has been structured to 
make this relatively simple; just change the values of certain environment 
variables in certain files, and you can extend Yona to support your own 
quirky programming language or task runner fairly easily.

### run.bash & compile.bash

The most important variables are `COMPILERS` and `RUNNERS`. These set the 
shell commands used to run & compile individual files. The shell command 
also uses the following substitutions:
- %  -> the filename
- %< -> the "name part" of the filename, i.e. the filename without extension
- %+ -> the "name part" + the extension `.yonax`

#### example

```bash
# run.bash
declare -a RUNNERS=(
    [go]="go run %"
    [py]="python3 %"
    [hs]="runghc %"
    [java]="java %<"
)
```

```bash
# compile.bash
declare -a COMPILERS=(
    [c]="gcc % -o %+"
    [go]="go build % -o %+"
    [hs]="ghc -Wno-tabs %"
    [java]="javac %"
)
```

So, in this example, yona would try to compile a C source file called 
`program.c` to a binary file called `program.yonax`, which it can then run 
with `yona -f run program.c`.
You can also see here why the `run` and `compile` commands are separate: the 
Go language can be run directly with `go run`, but it can also be compiled 
first. Having the commands be separate allows you to use go either way.

### task_runners.bash

This file sets the task runner information, as well as the priority order 
for different task runners.

#### example

```bash
# task_runners.bash

# You can add support for another task runner here by writing your own
# function named "tr_set_{TASK RUNNER NAME}" like the examples below, and
# adding TASK RUNNER NAME to the array variale $TASK_RUNNERS at the bottom.
function tr_set_make {
  # Runs a task with this task runner.
  # Parameters:
  # $1 = The name of the task
  function tr_run {
    make $1
  }
  # Prints the name of any task file in the current directory to stdout.
  # Must error if no task file for this task runner is in the current 
  # directory.
  # Must not print anything else to stdout.
  # Its stderr will be redirected to null.
  # Parameters: none
  function tr_file {
    ls Makefile || ls makefile
  }
  # Lists tasks in a given task runner file of this runner
  # Parameters:
  # $1 = The given task runner file
  function tr_list {
    cat $1 |
      sed 's/^\([^.:][^:]*\):/\x1b[33m\1\x1b[0m:/'
  }
  # Tests whether a given task is in a given task runner file.
  # Parameters:
  # $1 = The given task
  # $2 = The given task runner file to search in
  function tr_hastask {
    grep "^$1:" "$2"
  }
}

function tr_set_pnpm {
  function tr_run {
    pnpm run "$1"
  }
  function tr_file {
    ls package.json
  }
  function tr_list {
    pnpm run
  }
  function tr_hastask {
    grep "    \"${1}\":" "$2"
  }
}


# This sets the priority order for task runners, highest to lowest
declare -a TASK_RUNNERS=(
    make
    pnpm
)
```
