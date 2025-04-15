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

function tr_set_just {
  function tr_run {
    just "$1"
  }
  function tr_file {
    ls Justfile || ls justfile || ls JUSTFILE
  }
  function tr_list {
    just --list
  }
  function tr_hastask {
    just --summary | grep "$1"
  }
}

function tr_set_yona {
  function tr_run {
    source .yona
    $1
  }
  function tr_file {
    ls .yona
  }
  function tr_list {
    cat .yona |
      sed 's/^function \([^[:blank:]]\+\) {/function \x1b[33m\1\x1b[0m {/'
  }
  function tr_hastask {
    grep "^function $1\\(()\\)\\? {" "$2"
  }
}

# This sets the priority order for task runners, highest to lowest
declare -a TASK_RUNNERS=(
	yona
	make
	pnpm
	just
)
