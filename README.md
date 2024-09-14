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

To install yona, clone this repo and run `sudo make install`.

## Usage

```bash
yona PROJECT_COMMAND
yona [-l|--list] [DIRECTORY]
yona [-f|--file] [run|compile] FILE
yona [-s|--shell] SHELL_COMMAND
ysh SHELL_COMMAND
```

### `yona {PROJECT_COMMAND}`

Run the shell script given by PROJECT_COMMAND at project root. See [Project 
Commands](#project-commands) for more information on how a project command 
is specified.

### `yona --list [DIRECTORY]`

List available commands. See [Project Commands](#project-commands) form more 
information.

### `yona --shell {SHELL_COMMAND}`

Same as [`ysh {SHELL_COMMAND}`](#ysh-SHELL_COMMAND).

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

### `ysh SHELL_COMMAND`

Run SHELL_COMMAND at project root. See [Project Root](#project-root) for 
more information.


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
1. yona determines whether the pwd is in a git repository; if so, the 
   location of the `.git` directory is project root.
2. yona does the same thing for mercurial
3. yona recursively moves up the file system hierarchy, starting at the 
   current working directory, only stopping when it finds a 
   `.yona`/`Makefile`/`package.json` file.


## Configuration

The exact behaviour of yona can be configured using files in the directory
`$XDG_CONFIG_DIR/yona` or `~/.config/yona`. Currently this consists of two 
files, `run` and `compile`. These have the same format: a file extension, 
followed by an equals sign, followed by a shell command that runs/compiles 
files with that extension. The shell command also uses the following 
substitutions:
- %  -> the filename
- %< -> the "name part" of the filename, i.e. the filename without extension
- %+ -> the "name part" + the extension .yonax

### Example

~/.config/run
```
go = go run %
py = python3 %
hs = runghc %
java = java %<
```

~/.config/compile
```
c = gcc % -o %+
go = go build % -o %+
hs = ghc -Wno-tabs %
java = javac %
```

So, in this example, yona would try to compile a C source file called 
`program.c` to a binary file called `program.yonax`, which it can then run 
with `yona -f run program.c`.
You can also see here why the `run` and `compile` commands are separate: the 
Go language can be run directly with `go run`, but it can also be compiled 
first. Haing the commands be separate allows you to use go either way.
