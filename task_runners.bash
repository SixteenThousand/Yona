# The function name here is the task runner name (as in TASK_RUNNERS), 
# prefixed by 'tr_'
function tr_make {
  # The command to run a task. Will be prefixed by the task name.
	TR_RUNCMD=make
  # The file in which this task runner keeps its tasks.
  # Yona will match against this case insensitively.
	TR_FILE=Makefile
  # The commands used to print a list of all tasks, and to test whether a
  # task file contains a task of the given name.
  # The '%f' here will be replaced by the name of the relevant task runner 
  # file. and the '%t' by the task name.
	TR_LISTCMD='cat %f'
  TR_TESTCMD="grep '^%t: ' %f"
}

function tr_pnpm {
	TR_RUNCMD='pnpm run'
	TR_FILE='package.json'
	TR_LISTCMD='pnpm run'
  TR_TESTCMD="grep '    ""%t"":' %f"
}

function tr_just {
	TR_RUNCMD='just'
	TR_FILE='justfile'
	TR_LISTCMD='just --list'
  TR_TESTCMD="just --summary | grep '%t'"
}

function tr_yona {
	TR_RUNCMD='yona_taskrunner'
	TR_FILE='.yona'
  TR_LISTCMD='cat %'
  TR_TESTCMD="grep '^\(function\)\?%t() {\|^function %t\(()\)\? {' %f"
}

# This sets the priority order for task runners, highest to lowest
declare -a TASK_RUNNERS=(
	yona
	make
	pnpm
	just
)
