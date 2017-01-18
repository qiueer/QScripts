#!/bin/sh
## by qjq@20161216
##
BACKUP_DIRROOT='/home/albert/superman'
CURR_DATE=$(date +"%Y%m%d")
RMT_NAS_IP='10.17.131.11'
BACKUP_PROJ_NAME=kcbp
DEST_NAME=${BACKUP_PROJ_NAME}_${CURR_DATE}.tar.gz
LOCAL_IP=$(/sbin/ifconfig |grep -E 'bond0|eth0' -A3 |  grep 'inet addr' | awk '{print $2}' | awk -F':' '{print $2}'
)

INCLUDE_FILES="kcbplogs/calllist/LBMCALL_${CURR_DATE}.LST  kcbplogs/log64/biz/${CURR_DATE} kcbplogs/log/biz/${CURR_DATE}  kcbplogs/log64/run/${CURR_DATE}  kcbplogs/log/run/${CURR_DATE} kcbp/bin64/secusettLog_${CURR_DATE}.log kcbp/bin64/debug.log"

inc_str=""
for tarfile in $(echo "${INCLUDE_FILES}");do
        ABS_PATH=${BACKUP_DIRROOT}/${tarfile}
        [ -f ${ABS_PATH} ] || [ -d ${ABS_PATH} ] && inc_str="${inc_str} ${tarfile}"
done

cd $BACKUP_DIRROOT
## delete
[ -f ${DEST_NAME} ] && rm -fr ${DEST_NAME}
## archive
if [ "x${inc_str}" = "x" ] ;then
	echo "[WARN] File Not Exist.INCLUDE_FILES: ${INCLUDE_FILES}"
	exit 1
fi
echo "tar czvf /tmp/${DEST_NAME} ${inc_str}"
tar czvf /tmp/${DEST_NAME} ${inc_str}

RMT_DEST_DIR="/loghis/sbtps_cams/kcbp/${CURR_DATE}/${LOCAL_IP}/"


ssh ${RMT_NAS_IP} -C "mkdir -p ${RMT_DEST_DIR}"
scp /tmp/${DEST_NAME} ${RMT_NAS_IP}:${RMT_DEST_DIR}

if [ $? -eq 0 ];then
	rm -rvf /tmp/${DEST_NAME}
fi

echo "RMT IP: ${RMT_NAS_IP}"
echo "Dest Dir: ${RMT_DEST_DIR}"