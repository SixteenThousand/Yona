function main {
  printf '\x1b[1;35m========== Tests ==========\x1b[0m\n'
  # export assert functions so tests can use them when running in subshells;
  # see below
  local asserts="$(declare -F | cut -d ' ' -f 3 | grep '^assert')"
  export -f $asserts
  local tests="$(declare -F | cut -d ' ' -f 3 | grep '^test_')"
  local test_count="$(echo $tests | wc -w)"
  declare -i err_count=0
  for t in $tests; do
    setup
    # We run each test in a subshell so that asserts can use the exit builtin
    export -f $t
    if ! bash --norc --noprofile -c $t; then
      printf "\x1b[31m${t} failed!\x1b[0m\n"
      : $((err_count++))
    fi
    teardown
  done
  if [[ "$err_count" = 0 ]]; then
    printf "\x1b[1;32mAll ${test_count} tests passed!\x1b[0m\n"
  else
    printf "\x1b[1;31m${err_count} of ${test_count} tests failed!\x1b[0m\n"
  fi
}

function assert_output {
  local cmd=$1
  local expected=$2
  local got=$($cmd)
  if [[ "$got" != "$expected" ]]; then
    cat <<- EOF
Output of Command <${cmd}>:
expected:
  <${expected}>
got:
  <${got}>
EOF
    exit 1
  fi
}

function assert {
  if ! [[ $@ ]]; then
    cat <<- EOF
Test
  [[ $@ ]]
failed
EOF
    exit 1
  fi
}

function assert_retcode {
  local cmd=$1
  local expected=$2
  $cmd
  local got="$?"
  if [[ "$got" != "$expected" ]]; then
    cat <<- EOF
Expected return code <${expected}>
from command <${cmd}>,
but got <${got}>
EOF
    exit 1
  fi
}

function assert_run {
  local cmd=$1
  if ! ${cmd}; then
    cat <<- EOF
Command <${cmd}> failed
EOF
    exit 1
  fi
}

function setup {
  TESTDATA="$(mktemp -d yonatest-XXX)"
}

function teardown {
  rm -r $TESTDATA
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
