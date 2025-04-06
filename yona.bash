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
      get_size
      return
      ;;
    -h|--help)
      print_help
      return
      ;;
    -v|--version)
      echo -e "Yona, \x1b[3mThe script that stands in the blush of the build\x1b[0m, version $YONA_VERSION"
      return
      ;;
    *)
      run_task "$2"
      return
      ;;
  esac
}

# get options and command
cmd=$1
arg=$2
if [[ $cmd = '-v' || $cmd = '--version' ]]; then
  NOPAGER=1
fi
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--no-pager) NOPAGER=1;;
    -t|--task-runner)
      TASK_RUNNERS=( $2 )
      shift
      ;;
  esac
  shift
done

# check if we're actually connected to a terminal
if tty 2>&1 >/dev/null; then
  if [[ -z $NOPAGER ]]; then
    yona_cmd $cmd $arg | less -R
  else
    yona_cmd $cmd $arg
  fi
else
  yona_cmd $cmd $arg | sed -e 's/\x1b\[[^m][^m]*m//g'
fi
