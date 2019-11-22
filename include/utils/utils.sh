#!/bin/bash

# A list of usefull functions

# CHECKROOT
# Check if a command is executed with root privileges
function checkroot() {
  if [ $(id -u) -ne 0 ]
  then
    echo "You're not root! Try execute: sudo $0"
  fi
}

function progress_bar()
{
    local process_pid=$1
    local label=$2
    pid=$! # Process Id of the previous running command
    spin[0]="-"
    spin[1]="\\"
    spin[2]="|"
    spin[3]="/"

    echo -n "[$label] ${spin[0]}"
    while kill -0 $process_pid 2>/dev/null
    do
        for i in "${spin[@]}"
        do
            echo -ne "\b$i"
            sleep 0.1
        done
    done
    echo -ne "\bCOMPLETED\n"
}
