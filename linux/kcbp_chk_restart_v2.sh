#!/bin/sh
#by qjq@0112
#
CURDIR=$(cd $(dirname ${BASH_SOURCE[0]});pwd)
DAY_OF_WEEK=$(date +"%u")
NOW_HOUR=$(date +"%k")
NOW_MINUTE=$(date +"%M" | awk '{print int($0)}')
MNI_IN_ONEDAY=$[${NOW_HOUR}*60+${NOW_MINUTE}]

BUS_START_MINUTES=$[8*60+30]
BUS_END_MINUTES=$[23*60]

## 测试时打开
#BUS_START_MINUTES=$[7*60+30]
#BUS_END_MINUTES=$[8*60]

BIN64_PATH='/home/cts/kcbp/kbssuser/kcbp/bin64'
CURR_DT=$(date +"%Y%m%d%H%M%S")

function restart()
{
	cd ${BIN64_PATH}
	./kcbpsrvdetail stop
	./kcbpsrvdetail kill
	./kcbpsrvdetail clean
	./killipc
	./killshm
	sleep 2
	
	## check if need to kill force
	ps -ef | grep kcbpsrvdetail | grep kbssuser
	if [ $? -ne 0 ];then
		echo "[INFO] Force Kill"
		ps -ef | grep kcbpsrvdetail | grep kbssuser | grep -v grep | awk '{print $2}' | xargs kill -9
	fi
	
	echo "[INFO] Start"
	./kcbpsrvdetail start >/dev/null 2>&1 &
	sleep 2
	
	echo "[INFO] Check"
	./kcbpsrvdetail list

}

function check_and_restart()
{
	cd ${BIN64_PATH}
	
	local basetime=120000
	local max_cnt=30
	local max_check=2
	
	## 测试时打开
	#local basetime=2
	#local max_cnt=1
	#local max_check=1
	
	local match_cnt=0
	allstr=""
	for((i=1;i<=${max_check};i++));do
		resstr=$(./getsnap2 ./ 2>/dev/null)
		if [ $? -ne 0 ];then
			resstr=$(./getsnap ./ 2>/dev/null)
		fi
		if [ $? -ne 0 ];then
			echo "[INFO] No getsnap2 or getsnap Found."
			exit 1
		fi

		num=$(echo "${resstr}" | grep 'CostTime'|awk -F':' '{print $2}'|awk -F'ms'  "{if (\$1>${basetime}) {print $1}}" | wc -l)

		if [ "x${num}" = "x" ];then
			echo "[INFO] No Process CostTime > ${basetime},Exit."
			break
		fi

		if [ ${num} -lt ${max_cnt} ];then
			echo "[INFO] Number Of Process CostTime > ${basetime} Is: ${num}, Less Than ${max_cnt},Exit."
			break
		fi
		match_cnt=$[match_cnt+1]
		allstr="${allstr}${resstr}\n"
		sleep 1
	done

	if [ ${match_cnt} -ne ${max_check} ];then
		echo "[INFO] Check OK."
		echo "[INFO] Max Check:${max_check}, Match Count:${match_cnt}"
		return
	fi
	
	echo "[WARN] The Number of Process(Base Time>${basetime}ms) is:${num}, that > ${max_cnt} counts"
	echo "[INFO] Try to Restart:"
	restart
	
	#LOGDIR=$CURDIR/log
	LOGDIR=/tmp/kcbp_check_log
	mkdir -p ${LOGDIR}
	LOGPATH=${LOGDIR}/${CURR_DT}.log
	echo -e "[$(date +"%Y%m%d %H:%M:%S")]\n${allstr}" > ${LOGPATH}
	echo "[INFO]"
	echo "LOGPATH: ${LOGPATH}"
}

## weekday
if [ ${DAY_OF_WEEK} -gt 0 ] && [ ${DAY_OF_WEEK} -lt 6 ];then
	if [ ${MNI_IN_ONEDAY} -le ${BUS_END_MINUTES} ] && [ ${MNI_IN_ONEDAY} -ge ${BUS_START_MINUTES} ];then
		nt=$(date +"%Y%m%d %H:%M:%S")
		echo "[INFO] Business Time."
		exit 1
	fi
	check_and_restart
fi

## weekend
if [ ${DAY_OF_WEEK} -gt 5 ];then
	check_and_restart
fi
