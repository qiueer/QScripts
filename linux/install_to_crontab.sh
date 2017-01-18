#!/bin/bash

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]});pwd)
SCP_NAME=cut_nginx_log.sh
TMP_CRON_FILE=/tmp/crontab_tmp_qjq
BACKUP_CRONTAB_FILE=/tmp/crontab_back_$(date +"%Y%m%d%H%M%S")
SCPFILE=${CURDIR}/${SCP_NAME}
TODIR=$HOME
DEST_SCPFILE=${TODIR}/${SCP_NAME}
EXECTOR="bash"

if [ ! -f ${SCPFILE} ];then
	echo "[WARN] Script File Not Exist: ${SCPFILE}."
	exit 1
fi

## 目标文件存在则先备份
if [ -f ${DEST_SCPFILE} ];then
	echo "[INFO] Script File Exist: ${DEST_SCPFILE}, Try to Backup and Delete."
	prefix=${SCP_NAME%.*}
	subfix=${SCP_NAME##*.}
	backup_name=${prefix}_$(date +"%Y%m%d%H%M%S").${subfix}
	[ "x${subfix}" = "x" ] && backup_name=${prefix}_$(date +"%Y%m%d%H%M%S")
	cp -frv ${DEST_SCPFILE} ${TODIR}/${backup_name}
	if [ $? -eq 0 ];then ## 备份完则删除
		rm -frv ${DEST_SCPFILE} 
	fi
fi

## 复制脚本到目标位置
cp ${SCPFILE} ${DEST_SCPFILE}

## 备份crontab
echo "[INFO]"
echo "Backup Crontab to: ${BACKUP_CRONTAB_FILE}"
crontab -l > ${BACKUP_CRONTAB_FILE}

add_time=$(date +"%Y%m%d %H:%M:%S")
crontab -l | grep -v "${SCP_NAME}" > ${TMP_CRON_FILE}
echo "## add '${SCP_NAME}' by qjq@${add_time}" >>  ${TMP_CRON_FILE}
echo "0 0 * * * ${EXECTOR} ${DEST_SCPFILE} >/dev/null 2>&1" >> ${TMP_CRON_FILE}
crontab ${TMP_CRON_FILE}

echo "=============="
echo "    SUMMARY   "
echo "=============="
echo -e "SCRIPT:\n${DEST_SCPFILE}"
echo -e "CRONTAB:"
crontab -l | grep "${SCP_NAME}" | grep -Ev '^$'
