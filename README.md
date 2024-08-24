## Yona
### The script that stands in the blush of the build

This is Yona, a script I use to help automate simple terminal tasks, mainly:
- running/compiling the current file I'm editing
- finding the top-level of a project and running the relevant build script

It is designed primarily just to be hooked up to an editor's terminal 
emulator.

---

### Requirements

- Windows 10
- ![Ripgrep](https://github.com/BurntSushi/ripgrep)

---

### Usage

- **Running/Compiling**
	```
	yona run -path PATH_TO_FILE -name FILENAME -ext FILE_EXTENSION
	yona compile -path PATH_TO_FILE -name FILENAME -ext FILE_EXTENSION
	```
	Note that `FILENAME` does *not* include file extensions.

- **Running your own commands at the top-level of a project**
	```
	yona init
	```
	This creates a file called .yona in your project's top-level directory 
	with the following contents:
	```
    show = ls
	```
	This is just here as demonstation of the format; `ALIAS_NAME;;COMMAND`.
	To run this command, just run
	```
	yona show
	```
	from anywhere in the project.<br/>
	Naturally this means that you can't call your own commands any of:
	- init
	- run
	- compile.

That's it, really.

---
