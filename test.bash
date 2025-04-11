function main {
  local tests="$(declare -F | cut -d ' ' -f 3 | grep --color=never '^test_')"
  local test_count="$(echo $tests | wc -w)"
  local err_count
  declare -i err_count=0
  for t in $tests; do
    if ! $t; then
      printf "\x1b[31m${t} failed!\x1b[0m\n"
      : $((err_count++))
    fi
  done
  if [[ $err_count = 0 ]]; then
    printf "\x1b[1;32mAll ${test_count} tests passed!\x1b[0m\n"
  else
    printf "\x1b[1;31m${err_count} of ${test_count} tests failed!\x1b[0m\n"
  fi
}

function assert_output {
  local cmd=$1
  local expected=$2
  local got=$($cmd)
  if [[ $got != $expected ]]; then
    cat <<- EOF
Failure, line $(caller)
Output of Command <$cmd>:
expected:
  <$expected>
got:
  <$got>
EOF
    return 2
  fi
}

function test_compile {
  assert_output 'echo goat' goat
}

function teardown {
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

main >&2
