START_DIR=$(pwd)
TESTDATA=$(pwd)/scratch/testdata
if [ "$(basename $PWD)" != Yona ]
then
	echo 'Please source this script from the project toplevel directory' >&2
	exit 1
fi
mkdir --parents $TESTDATA
cd $TESTDATA
OLD_PS1=$PS1
PS1='yona-dev: \w\n> '

help() {
	cat <<- EOF
	Source (do not execute!) this script to access convenience functions for 
	interactive testing. Run 'help' to see what functions are available

	Usage:
	    single_file
	Make files for testing single file mode
	    project {path}/{package.json,Makefile,.yona}
	Make files & directories for testing project mode.
	The any number of the options in the braces can be specified,
	so if you want a Makefile & a .yona file, run
	        project ./.yona ./Makefile
	    clean
	Remove current testign files from the above commands. Is run automatically
	by the previous two commands
	    quit
	Go back to your normal shell session
	EOF
}

clean() {
	cd $TESTDATA
	if [ -n "$TESTDATA" ]
	then
		rm -rf $TESTDATA/*
		rm -rf $TESTDATA/.*
	fi
}

single_file() {
	OLD_DIR=$PWD
	cd $TESTDATA
	clean
	cat > hello.go <<- EOF
	package main
	func main() {
	    println("Hello, World! - from Go!")
	}
	EOF
	cat > hello.c <<- EOF
	#include <stdio.h>
	int main() {
	    printf("Hello, World! - from C!\n");
	}
	EOF
	cat > hello.py <<- EOF
	print("Hello, World! - from python!")
	EOF
	cat > Hello.java <<- EOF
	class Hello {
	    public static void main(String[] args) {
	        System.out.println("Hello, World! - from Java!");
		}
	}
	EOF
	cd $OLD_DIR
}


project() {
	OLD_DIR=$PWD
	cd $TESTDATA
	clean
	mkdir -p very/deep/project
	mkdir .git
	for arg in $@
	do
		case $arg in
			*Makefile)
				echo -e "makeCommand:\n\techo "\
					"Running a command from a makefile!"\
					"\nbuild:\n\techo '+++make build recipe+++'" \
					> $arg
				;;
			*.yona)
				cat > $arg <<- EOF
				yonaCommand = echo "Running a command from a .yona file!"
				build = echo '+++yona build script+++'
				EOF
				;;
			*package.json)
				cat > $arg <<- EOF
				{
				  "name": "temp",
				  "version": "1.0.0",
				  "description": "",
				  "main": "index.js",
				  "scripts": {
					"npmCommand": "echo Running an npm script!",
					"build": "echo +++npm build script+++"
				  },
				  "keywords": [],
				  "author": "",
				  "license": "ISC"
				}
				EOF
				;;
		esac
	done
	cd $OLD_DIR
}

yona() {
	$START_DIR/yona $@
}

quit() {
	unset -f help clean single_file project yona
	PS1=$OLD_PS1
	cd $START_DIR
}
