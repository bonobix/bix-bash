#!/bin/bash

: <<'COMMENT'

Loop per killare processi SidecarRelay|photolibraryd su MAC

COMMENT

while true; do
  # List processes and filter out the grep command itself
  pids=$(ps aux | grep -E 'SidecarRelay|photolibraryd' | grep -v grep | awk '{print $2}')
  
  # Kill each matching process
  for pid in $pids; do
    echo "Killing process with PID: $pid"
    kill -9 "$pid"
  done
  
  # Pause for 1 second before checking again
  sleep 1
done
