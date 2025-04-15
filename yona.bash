#!/usr/bin/env bash

# This will have a trailing newline
YONA_VERSION='m4_syscmd(git describe --tags --dirty)'


m4_include(help.bash)

m4_include(task_runners.bash)

m4_include(run.bash)

m4_include(compile.bash)

# Print a formatted message to stderr and exit the current shell.
# Note that this may not cause yona to exit
# Parameters:
# $1 = The error message
# $2 = The exit code of the shell; defaults to 1
function error {
  echo -e "\x1b[31mYona Error: $1\x1b[0m" >&2
  exit ${2:-1}
}

# Get file extension, name, name part, & parent directory
# Parameters:
# $1 = The absolute path to the file
function get_fileinfo {
	PARENT=$(dirname $1)
	NAME=$(basename $1)
	NAME_PART=${NAME%%.*}
	EXT=${NAME##*.}
}

# Does its level best to "run" the given file, whatever that may mean for that 
# file. Mostly it will just choose the right interpreter for the job (python, 
# lua, etc.), but if it finds an executable whose name is the "name part" of
# the file, or the file itself is executable, it will try to run that instead.
# Parameters:
#	$1 = The absolute path to the file
function run_file {
	echo -e "Preparing to run...\n\n" >&2
  local end_msg="\n\nProgram might have run!"
  local status_code
	get_fileinfo $1
	cd $PARENT
  if [[ -x $NAME ]]; then
    ./$NAME
    status_code=$?
    echo -e $end_msg >&2
    return $status_code
  fi
	if [[ -x "$NAME_PART" ]]; then
		./$NAME_PART
    status_code=$?
    echo -e $end_msg >&2
    return $status_code
	fi
	if [[ -n "${RUNNERS[$EXT]}" ]]; then
		# replace %< & % with name part & name, and then run it
		local to_run=${RUNNERS[$EXT]/\%\</$NAME_PART}
		to_run=${to_run/\%\+/$NAME_PART}
		eval "${to_run/\%/$NAME}"
    status_code=$?
    echo -e $end_msg >&2
    return $status_code
	fi
}

# Compiles the given file with the relevant program based on the file's 
# extension.
# Parameters:
#	$1 = The absolute path to the file
function compile_file {
	echo -e "Preparing to compile...\n\n" >&2
	get_fileinfo $1
	cd $PARENT
	if [[ -n ${COMPILERS[$EXT]} ]]; then
		# replace %< & % with name part & name, and then run it
		local to_run=${COMPILERS[$EXT]/\%\</$NAME_PART}
		to_run=${to_run/\%\+/$NAME_PART}
		eval "${to_run/\%/$NAME}"
    local status_code=$?
		echo -e "\n\nCompiled! Maybe!" >&2
		return $status_code
	fi
}

function get_project_root {
  local start_dir=$PWD
  local dir
  for tr_name in ${TASK_RUNNERS[@]}; do
    dir=$start_dir
    eval "tr_set_$tr_name"
    while [[ $dir != / ]]; do
      local task_file=$(cd "$dir" && tr_file 2>/dev/null)
      if [[ -n $task_file ]]; then
        PROJECT_ROOT=$dir
        return
      else
        dir=$(dirname $dir)
      fi
    done
  done
  error 'No task runner files found. Are you in a project?'
}
  
function get_size {
  get_project_root
  cd "$PROJECT_ROOT"
  if [[ -n $1 ]]; then
    find -type f -name "*.$1" | xargs wc -l
  elif git status 2>&1 >/dev/null; then
    git ls-files | xargs wc -l
  else
    find -type f | xargs wc -l
  fi
}

function shell_cmd {
  get_project_root
  cd "$PROJECT_ROOT"
  eval "$1"
}

function project_setup {
  echo "TODO"
}

function list_tasks {
  local start_dir=$PWD
  local dir
  local path
  for tr_name in ${TASK_RUNNERS[@]}; do
    dir=$start_dir
    eval "tr_set_$tr_name"
    while [[ $dir != / ]]; do
      local task_file=$(cd "$dir" && tr_file 2>/dev/null)
      if [[ -n $task_file ]]; then
        local task_file_path=$(realpath --relative-to=${start_dir} ${dir}/${task_file})
        local header="${tr_name} - ${task_file_path}"
        # Note the ANSI sequences need to be reset for each line for less
        printf "\x1b[1;36m${header}\n\x1b[1;36m"
        printf '*%.0s' $(seq ${#header})
        printf '\x1b[0m\n'
        cd "$dir" && tr_list "$task_file" && cd "$start_dir"
        break
      fi
      dir=$(dirname $dir)
    done
  done
}

function run_task {
  local task=$1
  local start_dir=$PWD
  local dir
  local path
  for tr_name in ${TASK_RUNNERS[@]}; do
    dir=$start_dir
    eval "tr_set_$tr_name"
    while [[ $dir != / ]]; do
      local task_file=$(cd "$dir" && tr_file 2>/dev/null)
      if [[ -n $task_file ]]; then
        cd "$dir"
        if tr_hastask "$task" "$task_file" 2>&1 >/dev/null; then
          tr_run "$task"
          return
        fi
        cd "$start_dir"
        break
      fi
      dir=$(dirname $dir)
    done
  done
  error 'Invalid task name!'
}

function yona_cmd {
  case $1 in
    -l|--list)
      list_tasks "$2"
      return
      ;;
    -c|--compile)
      compile_file "$2"
      return
      ;;
    -r|--run)
      run_file "$2"
      return
      ;;
    -s|--shell)
      shell_cmd "$2"
      return
      ;;
    --setup)
      project_setup "$2"
      return
      ;;
    --size)
      get_size "$2"
      return
      ;;
    -h|--help)
      print_help
      return
      ;;
    -v|--version)
      printf "Yona, version $YONA_VERSION\x1b[3mThe script that stands in the blush of the build\x1b[0m\n"
      return
      ;;
    *)
      run_task "$1"
      return
      ;;
  esac
}

# get options and command
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--pager) PAGER=1;;
    -t|--task-runner)
      TASK_RUNNERS=( $2 )
      shift
      ;;
    *)
      if [[ -z $cmd ]]; then
        cmd=$1
      else
        arg=$1
      fi
  esac
  shift
done

# check if we're actually connected to a terminal
if [[ -t 1 ]]; then
  if [[ -n $PAGER ]]; then
    yona_cmd $cmd $arg 2>&1 | less -R
  else
    yona_cmd $cmd $arg
  fi
else
  yona_cmd $cmd $arg | sed -e 's/\x1b\[[^m][^m]*m//g'
fi
