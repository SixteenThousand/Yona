function main {
  local cmd=$1
  local arg=$2
  shift 2
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
  case $cmd in
    -l|--list)
      list_tasks "$arg"
      return
      ;;
    -c|--compile)
      compile_file "$arg"
      return
      ;;
    -r|--run)
      run_file "$arg"
      return
      ;;
    -s|--shell)
      shell_cmd "$arg"
      return
      ;;
    --setup)
      project_setup "$arg"
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
      run_task "$arg"
      return
      ;;
  esac
}

# check if we're actually connected to a terminal
if tty 2>&1 >/dev/null; then
  if [[ -z $NOPAGER ]]; then
    main $@ | less -R
  else
    main $@
  fi
else
  main $@ | sed -e 's/\x1b\[[^m][^m]*m//g'
fi
