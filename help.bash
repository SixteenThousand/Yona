function print_help {
  cat <<- EOF
Yona, [3mthe script that stands in the blush of the build[0m

This script does 2 things:
  1. Makes setting up "code running" functionality in an editor simpler
  2. Makes it easier to deal with task running (a la make or npm) easier

  [33mUsage[0m
      yona PROJECT_COMMAND [options]
      yona COMMAND ARGUMENT [options]
    
    In the first form, run task/recipe/whatever PROJECT_COMMAND with 
    whatever task runner has PROJECT_COMMAND as a task/whatever. See 
    [33mProject Root[0m for details on how this is found.
    
    In the second form, yona takes a command in the form of a GNU-style 
    flag, which may take a non-flag argument See below for available 
    commands. 
      
  [33mCommands[0m
    [34myona -l|--list [DIRECTORY][0m
      List the available project commands accesible from the current 
      directory. Commands will be listed in order for priority for use in 
      "yona PROJECT_COMMAND".
    [34myona -c|--compile FILE[0m
      Attempt to compile FILE using the relevant command.
    [34myona -r|--run FILE[0m
      Attempt to run FILE using the relevant command.
      Use the following algorithm:
        1. If the file is executable, just run the file.
        2. If there is an executable in the same directory whose name is the 
           name of FILE without any of its extensions, run that.
        3. Find a relevant intepreter to run the file.
      It will [3mnot[0m try to compile the file.
    [34myona -s|--shell SHELL_COMMAND[0m
      Run the bash/sh  command SHELL_COMMAND in project root.
    [34myona --size EXTENSION[0m
      Count the number of lines in the current project.
       - With EXTENSION, counts lines only in files that have extension 
         EXTENSION.
       - Without EXTENSION, uses git to find project files.
       - Without EXTENSION and outside a git repository, counts lines in all 
         files under project root.
    [34myona -h|--help[0m
      Print this message.
    [34myona -v|--version[0m
      Print version information
    
   [33mOptions[0m
     [34m-p|--pager[0m
       Page output with less.
     [34m-t|--task-runner TASK_RUNNER[0m
       Limit search for task runner files/project commands/project root to 
       TASK_RUNNER.
    
   [33mProject Root[0m
     The ancestor directory (that is, parent, or parent of parent, or parent 
     of parent of parent, and so on) of the current one that contains the 
     highest-priority task runner file (Makefile, package.json, etc.) and is 
     closest to the current working directory.
   
     Specifically, yona has a list a task runners. For each item in the 
     list, it looks in each parent directory for the associated task runner 
     file and stops as soon as it finds one.
     
     The same algorithm is used to find PROJECT_COMMAND, and by --list, 
     although in those cases it stops when the relevant command is found or 
     until all kinds of task runner files have been found
     
     If no task runner files are present in any ancestor directory, yona 
     will return an error.
     
   [33mTask Runners[0m
     Yona currently supports these task runners, ordered from highest 
     priority to least:
        $(echo ${TASK_RUNNERS[@]} | sed 's/ /\n        /g')
EOF
}
