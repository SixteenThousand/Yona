# Yona

### The script that stands in the blush of the build

This is Yona, a script I use to help automate simple terminal tasks, mainly:
- running/compiling the current file I'm editing
- finding the top-level of a project and running the relevant build script

It is designed primarily just to be hooked up to an editor's terminal emulator.

---

## Requirements

Yona should run on any Unix-like system.

For development, any C compiler should just be able to build it (see 
`Makefile` for how I do it).

---

## Usage

```
yona init {DIRECTORY}
yona list
ysh {SHELL_COMMAND}
yona {PROJECT_COMMAND}
yona [-h|--shell] {SHELL_COMMAND}
yona yona [-s|--single-file] [run|compile] {FILE_NAME}
```

### `yona init`

Create a `.yona` file in the directory specified. Uses the current working 
directory is none given.

### `yona list`

List available commands. See [Project Commands](#project-commands) form more 
information.

### `ysh {SHELL_COMMAND}`

Run SHELL_COMMAND at project root. See [Project Root](#project-root) for 
more information.

### `yona {PROJECT_COMMAND}`

Run the shell script given by PROJECT_COMMAND at project root. See [Project 
Commands](#project-commands) for more information on how a project command 
is specified.

### `yona [-h|--shell] {SHELL_COMMAND}`

Same as [`ysh {SHELL_COMMAND}`](#ysh-{SHELL_COMMAND}).

### `yona [-s|--single-file] [compile] {FILE_NAME}`

Compile FILE_NAME using the relevant software. Yona decides what software to 
use based on the file extension of FILE_NAME; so, for example, `yona 
--single-file compile thing.c` will use `gcc`. What exactly is used for each 
extension is specified in [the configuration file](#configuration).

If the relevant compilation process creates an executable, it will be named 
with the form `NAME_PART.yonax`, where NAME_PART is FILE_NAME minus the file 
extension. The extension used can be changed in the config file. 

### `yona [-s|--single-file] [run] {FILE_NAME}`

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
1. yona determines whether the pwd is in a git repository; if so, the 
   location of the `.git` directory is project root.
2. yona does the same thing for mercurial
3. yona recursively moves up the file system hierarchy, starting at the 
   current working directory, only stopping when it finds a 
   `.yona`/`Makefile`/`package.json` file.


## `.yona` File format

`.yona` files should have the format:
```
{PROJECT_COMMAND_NAME} = {SHELL_COMMAND}
```

## Configuration

Yona can be configured using a file located at 
`$XDG_CONFIG_DIR/yona/yona.toml`, or `~/.config/yona/yona.toml` if 
`$XDG_CONFIG_DIR` is not set.

The main options you would want to set are the run/compile options. The 
default configuration looks like this*:

```toml
# When run, yona will replace certain patterns in the run & compile scripts,
# as follows:
# % -> the filename
# %< -> the "name part" of teh filename, i.e. the filename without extension
# %+ -> the "name part" + the extension .yonax

[run]
bash = "bash %"
fish = "fish %"
go = "go run %"
hs = "runghc %"
java = "java %<"
js = "node %"
lisp = "sbcl --script %"
lua = "lua %"
mjs = "node %"
ml = "ocaml %"
php = "php %"
pl = "perl %"
ps1 = "pwsh %"
py = "python %"
rb = "ruby %"
sh = "bash %"
sql = "psql -f %"
ts = "node %+.js"

[compile]
c = "gcc % -o %+"
cpp = "g++ % -o %+"
go = "go build % -o %+"
hs = "ghc -Wno-tabs %"
java = "javac -Xlint:unchecked %"
ml = "ocamlc % %+"
rs = "rustc -A dead-code -o %+ %"
tex = "pdflatex -output-directory='tex-logs' % && mv tex-logs/%<.pdf ."
ts = "tsc --target esnext %"
```
