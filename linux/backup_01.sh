#!/bin/sh
## by qjq@20161216
##
APPDIR='/home/albert/superproj'
CURR_DATE=$(date +"%Y%m%d")
RMT_NAS_IP='192.168.1.1'
PROJECT_DIR=kcbp
DEST_NAME=${PROJECT_DIR}_${CURR_DATE}.tar.gz
LOCAL_IP=$(/sbin/ifconfig |grep -E 'bond0|eth0' -A3 |  grep 'inet addr' | awk '{print $2}' | awk -F':' '{print $2}'
)

INCLUDE_FILES="bin64/LBMCALL_${CURR_DATE}.LST  log64/biz/${CURR_DATE}  log64/run/${CURR_DATE}  bin64/secusettLog_${CURR_DATE}.log bin64/debug.log"

inc_str=""
for tarfile in $(echo "${INCLUDE_FILES}");do
        ABS_PATH=${APPDIR}/${PROJECT_DIR}/${tarfile}
        [ -f ${ABS_PATH} ] || [ -d ${ABS_PATH} ] && inc_str="${inc_str} ${PROJECT_DIR}/${tarfile}"
done

cd $APPDIR
## delete
[ -f ${DEST_NAME} ] && rm -fr ${DEST_NAME}
## archive
echo ${inc_str}
tar czvf /tmp/${DEST_NAME} ${inc_str}

RMT_DEST_DIR="/loghis/sbtps_cams/kcbp/${CURR_DATE}/${LOCAL_IP}/"
ssh ${RMT_NAS_IP} -C "mkdir -p ${RMT_DEST_DIR}"
scp /tmp/${DEST_NAME} ${RMT_NAS_IP}:${RMT_DEST_DIR}

if [ $? -eq 0 ];then
	rm -rvf /tmp/${DEST_NAME}
fi

echo "RMT IP: ${RMT_NAS_IP}"
echo "Dest Dir: ${RMT_DEST_DIR}"