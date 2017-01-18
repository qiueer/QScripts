#!/bin/bash
###
### qjq@20161109
###

PROCESS_NAME="thinkbus"
CHECK_STR="name=thinkbus"

PROJ_DIR=/home/deployop/thinkbus
CONFIG_PATH=${PROJ_DIR}/config
LOG_PATH=/home/deployop/applogs/thinkbus


cnt=$(ps -ef | grep "${CHECK_STR}" | grep -v grep | wc -l)
pid=$(ps -ef|grep "${CHECK_STR}" | grep -v grep | awk '{print $2}')
if [ $cnt -gt 0 ] ;then
	echo "[INFO] process:${PROCESS_NAME} had started, stop it first."
	echo "[INFO] Pid:${pid}"
	exit 1
fi

mkdir -p ${LOG_PATH}

cd ${PROJ_DIR}
cls_path=$CLASSPATH
for i in `ls ./lib/*.jar`;  do
    cls_path=$i:$cls_path
done

cls_path=$CONFIG_PATH:$cls_path
cls_path=./bin:$cls_path

echo "[INFO] start process:${PROCESS_NAME}"
java -server -Dname=thinkbus  -Dfile.encoding=GBK -classpath $cls_path -Xms256m -Xmx512m Main  > $LOG_PATH/out.log 2>&1 &
pid=$(ps -ef|grep "${CHECK_STR}" | grep -v grep | awk '{print $2}')
echo "[INFO] Pid:${pid}"
