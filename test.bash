## Mini testing framework for bash
function main {
  local stderr_dst=/dev/null
  if [[ -n $1 && $1 -gt 0 ]]; then
    stderr_dst=/dev/stdout
  fi
  echo $1
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
    if ! bash --norc --noprofile -c $t 2>$stderr_dst; then
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


## Help functions for tests
function dump_makefile {
  # can't use cat here; need actual tab characters
  echo -e "makeCommand:\n\techo "\
    "Running a command from a makefile!"\
    "\nbuild:\n\techo '${1}'"
}

function dump_npmfile {
  cat <<- EOF
{
  "name": "temp",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "npmCommand": "echo Running an npm script!",
  "build": "echo '${1}'",
    "test": "echo tests!"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF
}

function dump_dotyonafile {
  cat > .yona <<- EOF
function build {
  echo '${1}'
}
EOF
}


## Setup and teardown for each test
function setup {
  STARTDIR="$PWD"
  TESTDATA="$(mktemp -d yonatest-XXX)"
  cd "$TESTDATA"
  export YONA='../yona --no-pager'
}

function teardown {
  cd "$STARTDIR"
  rm -r "$TESTDATA"
}


## FINALLY! The actual goddamn tests!!
function test_c {
  local msg='Hello, World! - from C!'
  local file="${PWD}/see.c"
	cat > "$file" <<- EOF
#include <stdio.h>
int main() {
    printf("${msg}");
}
EOF
  $YONA --compile "$file" -n >/dev/null
  local exe="${file%.c}"
  assert -x "$exe"
  assert_output "$exe" "$msg"
  assert_output "$YONA --run '$file'" "$msg"
}

function test_go {
  local msg='Hello, World! - from Go!'
  local file="${PWD}/goe.go"
  cat > "$file" <<- EOF
package main
import "fmt"
func main() {
  fmt.Println("${msg}")
}
EOF
  assert_output "$YONA --run '${file}'" "$msg"
  $YONA --compile "$file"
  local exe="${file%.go}"
  # Change the file so that we can check that we run the compiled version
  # later
  cat > "$file" <<- EOF
package main
import "fmt"
func main() {
  fmt.Println("You should never see this message")
}
EOF
  assert -x "$exe"
  assert_output "$exe" "$msg"
  assert_output "$YONA --run '${file}'" "$msg"
}

function test_python {
  local file="${PWD}/pighthon.py"
  local msg='Hello, World! - from python!'
  cat > "$file" <<- EOF
print("${msg}")
EOF
  assert_output "$YONA --run '$file'" "$msg"
}

function test_java {
  local file="${PWD}/Jarvah.java"
  local msg='Hello, World! - from Java!'
  local exe="${file%.java}.class"
  cat > "$file" <<- EOF
class Jarvah {
  public static void main(String[] args) {
    System.out.println("${msg}");
  }
}
EOF
  $YONA --compile "$file"
  assert -e "$exe"
  assert_output "java '$exe'" "$msg"
  assert_output "$YONA --run '$file'" "$msg"
}


## Now to actually run all these lovely tests...
main $@ >&2
