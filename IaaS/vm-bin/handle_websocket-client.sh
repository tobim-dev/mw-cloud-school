#!/bin/bash

FILE=/home/adminuser/chat.log

USERID=${QUERY_STRING#userid=}

function forward_from_stdin_to_file {
  while read MSG; do echo "[$(date)] ${USERID}>${MSG}" >> $FILE; done
}

function forward_from_file_to_stdout {
  tail -n 0 -f $FILE --pid=$$
}

forward_from_file_to_stdout &
sleep 0.1
echo "${USERID} joined." >> $FILE

forward_from_stdin_to_file
