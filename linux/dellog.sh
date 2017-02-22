#!/bin/sh
##
## qjq@20170222
## 日志清理脚本
##
sptname=$0
sptname=$(echo ${sptname} | awk -F'/' '{print $NF}')

cnt=$(ps -ef | grep "${sptname}" | wc -l)
if [ ${cnt} -gt 4 ];then
	echo "[WARN] Too Much Process: '${sptname}', Count: ${cnt}, Exit."
	exit 1
fi

dbefore=$1
dend=$2

if [ $# -ne 2 ]; then
	echo "Usage: $0 begin end"
	exit 1
fi

if [ "x${dbefore}" = "x" ];then
	dbefore=30
fi

if [ "x${dend}" = "x" ];then
	dend=90
fi


function dellog
{
	local deldir=$1
	local del_dbefore=$2
	local del_dend=$3
	
	local beside_dir="/  /root/ /usr/local/ /usr/sbin/ /usr/bin/ /bin/ /home/ /sbin/ /sys/ /dev/ /data/ /lib/ /lib64/  /boot/ /usr/ /etc/"

	## 只能在以/结尾的目录下删除
	if [ ${deldir: -1} != '/' ];then
		echo "[WARN] Can not delete log with logdir subfix is not '/'"
		return 1
	fi
	
	## 排除目录
	for tmpdir in $(echo "${beside_dir}")
	do
		if [ "${tmpdir}" = "${deldir}" ];then
			echo "[WARN] Can not delete log in path:${tmpdir}"
			return 1
		fi
	done
	
	## 只删除存在的目录
	if [ ! -d ${deldir} ];then
		echo "Dir Not Exist! Dir:${deldir}"
		return 1
	fi
	
	if [ ${del_dbefore} -lt 10 ];then
			echo "Log files stored can not less 10 days!"
			return 1
	fi
	if [ ${del_dbefore} -gt ${del_dend} ];then
			echo "End day should great than begin day!"
			return 1
	fi
	
	cd $deldir
	## delete by filename
	for((i=${del_dbefore};i<=${del_dend};i++))
	do
		dstr1=$(date -d "${i} days ago" +%Y-%m-%d)
		dstr2=$(date -d "${i} days ago" +%Y%m%d)
		for dstr in $(echo "${dstr1} ${dstr2}")
		do
			[ "x${dstr}" = "x" ] && continue
			logstr_ary="*${dstr}*.log *${dstr}*log* *log*${dstr}*"
			echo "[INFO] Del log in dir:${deldir},logfile name like one of them:'${logstr_ary}'"
			for logfile in $(echo "${logstr_ary}")
			do
				[ "x${logfile}" = "x" ] && continue
				find ./ -type f -name "${logfile}" -exec rm -frv {} \;
			done

		done
	done
	
	## delete by modify time
	cd ${deldir}
	echo "[INFO] Del log in dir:${deldir},day before: ${del_dbefore}"
	find ./ ! -name "*.pid" -type f -mtime +"${del_dbefore}"  -exec rm -frv {} \;
	
	## clear *.out file
	echo "[INFO] clear *.out file"
	for outfile in $(find ./ -name "*.out" -type f)
	do
		du -sh ${outfile}
		echo >${outfile}
	done
	
	return 0

}

df_before=$(df -h)

DELLOG_PATHS="/wls/apache/applogs/ /wls/applogs/archvlog/ /wls/applogs/rtlog/"
for logdir in $(echo "${DELLOG_PATHS}")
do
	dellog ${logdir} ${dbefore} ${dend}
done

echo "[INFO] -->> filesystem before <<--"
echo "${df_before}"
echo
echo "[INFO] -->> filesystem after <<-- "
df -h