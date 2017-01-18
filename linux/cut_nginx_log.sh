#!/bin/bash
# by qjq@20170118
#

LOGDIR="/wls/apache/applogs"
filenames="host.access.log error.log"

cd $LOGDIR
for d in `find ./ -type d|grep -Ev '/$' | awk -F'/' '{print $2}'`;do
	SUB_LOGDIR=${LOGDIR}/${d}
	PIDFILE=${LOGDIR}/${d}/nginx.pid
	echo "====== ${d} ========"
	echo "[INFO]"
	echo "LOGPATH: ${SUB_LOGDIR}"
	echo "PIDFILE: ${PIDFILE}"

	if [ ! -f ${PIDFILE} ];then
		echo "[WARN] Not Exist Pidfile: ${PIDFILE}"
		continue
	fi
	
	flag=""
	for fn in $(echo "${filenames}");do
		logfile=${SUB_LOGDIR}/${fn}
		if [ "x${fn}" = "x" ];then
			continue
		fi
		if [ ! -f ${logfile} ];then
			echo "[INFO] Not Exist Log File: ${logfile}"
			continue
		fi
		
		prefix=${fn%.*}
		subfix=${fn##*.}
		pre_logfile=${SUB_LOGDIR}/${prefix}_$(date -d "yesterday" +"%Y%m%d").${subfix}
		if [ "x${subfix}" = "x" ];then 
			pre_logfile=${SUB_LOGDIR}/${prefix}_$(date -d "yesterday" +"%Y%m%d")
		fi

		echo "[INFO] Handle Log File: ${logfile}"
		mv ${logfile} ${pre_logfile}
		flag="1"
	done
	
	if [ "x${flag}" = "x" ];then
		continue
	fi
	
	#向nginx主进程发信号重新打开日志
	echo "[INFO] send signal to nginx to re-open log"
	echo "kill -USR1 `cat ${PIDFILE}`"
	kill -USR1 `cat ${PIDFILE}`

done
