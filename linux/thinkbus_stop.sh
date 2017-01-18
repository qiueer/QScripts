#!/bin/bash
###
### qjq@20161109
###

PROCESS_NAME="thinkbus"
CHECK_STR="name=thinkbus"

#kill Main pid
pidlist=$(ps -ef|grep "${CHECK_STR}" | grep -v grep | awk '{print $2}')
pidstr=$(echo "${pidlist}" | tr '\n' ';')

if [ "x${pidlist}" = "x" ];then
  echo "[INFO] Process: ${PROCESS_NAME} not exist. eixt."
  exit 1
fi

echo "[INFO] Process: ${PROCESS_NAME}"
echo "[INFO] Main Id list: ${pidstr}"
for pid in ${pidlist};do
   kill -9 $pid
   echo "KILL Pid: ${pid}"
done
