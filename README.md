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

## Usage

```bash
yona PROJECT_COMMAND
yona [-l|--list] [DIRECTORY]
yona [-f|--file] [run|compile] FILE
yona [-s|--shell] SHELL_COMMAND
```

### `yona {PROJECT_COMMAND}`

Run the shell script given by PROJECT_COMMAND at project root. See [Project 
Commands](#project-commands) for more information on how a project command 
is specified.

### `yona --list [DIRECTORY]`

List available commands. See [Project Commands](#project-commands) form more 
information.

### `yona --shell {SHELL_COMMAND}`

Run SHELL_COMMAND at project root. See [Project Root](#project-root) for 
more information.

### `yona --file compile FILE_NAME`

Compile FILE_NAME using the relevant software. Yona decides what software to 
use based on the file extension of FILE_NAME; so, for example, `yona 
--single-file compile thing.c` will use `gcc`. What exactly is used for each 
extension is specified in [the configuration](#configuration).

If the relevant compilation process creates an executable, it will be named 
with the form `NAME_PART.yonax`, where NAME_PART is FILE_NAME minus the file 
extension. The extension used can be changed in the config file. 

### `yona --file run FILE_NAME`

Run FILE_NAME, whatever that means for the file type in question. Yona uses 
the following algorithm to do this:
1. yona looks for a file named `NAME_PART.yonax` (see the compile option 
   above) to execute
2. if no such file is found, yona looks for a run command to use in its 
   configuration file (see [configuration](#configuration)


## Project Commands

A project command is one of:

1. a command listed in a .yona file
2. a make command
3. a `package.json` script

Project commands must be one word (i.e. a series of letters and `-` and `_` 
not separated by blanks). Commands are prioritised in the order given above, 
that is, yona will check for a `.yona`  file first and look for a `Makefile` 
*if and only if no `.yona` file is found*, and then if there is no 
`Makefile`, it will look for a `package.json`, and so on.

## Project Root

The "Project Root" of the current working directory is determined by yona 
using the following algorithm:
1. Check whether the current working directory contains a project commands 
   file (the file types listed in [Project Commands](#project-commands)).
   If it does, we are at project root.
2. Check whether the current working directory is the root of a source 
   control repository (currently only planned to support git and mercurial).
3. If current working directory is the root of the system, stop & display an 
   error message.
4. Go to the parent directory. Go to step 1.


## Configuration

The exact behaviour of yona can be configured using files in the directory
`$XDG_CONFIG_DIR/yona` or `~/.config/yona`. This consists of three files, 
`config.sh`, `run.sh` and `compile.sh`. These are shell scripts which set 
environment variables yona uses when running.

The most important settings are `COMPILERS` and `RUNNERS`. These sset the 
shell commands used to run & compile individual 
The shell command also uses the following substitutions:
- %  -> the filename
- %< -> the "name part" of the filename, i.e. the filename without extension
- %+ -> the "name part" + the extension .yonax

### Example

~/.config/run.sh
```bash
RUNNERS=(
    [go]="go run %"
    [py]="python3 %"
    [hs]="runghc %"
    [java]="java %<"
)
```

~/.config/compile.sh
```bash
COMPILERS=(
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

You can also set a message to printed before & after running/compilation by 
setting `START_MSG` & `END_MSG` in the `run.sh` & `compile.sh`.

`config.sh` sets other options; look at the default version of it in the 
configs directory for more information.

<!-- exclude everything after this point from man page -->
## Getting Started

Yona is written in bash version 5.2. It is not guaranteed to work on older 
versions of bash. It also requires grep (a GNU coreutil) and jq 
(<https://jqlang.github.io/jq/>) for parsing package.json files. If jq is 
not installed, yona will just ignore package.json files.

To install yona, clone this repo and run `make install` you will need to 
enter your system password to complete the installation.
