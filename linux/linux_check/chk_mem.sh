#!/bin/sh
# funciton : check sys mem
# by qiujingqin

percent=""
mega=""
debug=0

usage()
{
        echo "usage: $(basename $0) [-p:m:d]"
	echo "NAME"
	echo "	$(basename $0) - Check if memory meets requirements"
	echo "SYNOPSIS"
        echo "	-p the minimum available memory check, by percent"
        echo "	-m the minimum available memory check, by mega"
        echo "	-d debug"
        exit 1
}

while getopts ':p:m:d' opt
do
        case $opt in
                p) percent=$OPTARG ;;
                m) mega=$OPTARG ;;
		d) debug=1 ;;
                *) usage;;
        esac
done

if [ "x${percent}" = "x" ];then
	percent=10
fi

if [ "x${mega}" = "x" ];then
	mega=100
fi

if [ $debug -eq 1 ];then
		echo "Percent: ${percent}(%)"
		echo "Mega: ${mega}(M)"
		echo 
		echo "Memory Info:"
		cat /proc/meminfo
fi



avail_mem=$(cat /proc/meminfo  | grep 'MemAvailable' | awk '{print $2}')
total_mem=$(cat /proc/meminfo  | grep 'MemTotal' | awk '{print $2}')

## 两种计算方式，shell不支持浮点数运算，只能借助bc,awk
avail_mem_mb=$(expr ${avail_mem} / 1024)
# scale=2，保留两位小数
perc_avail=$(echo "scale=2;($total_mem-$avail_mem)*100/$total_mem"|bc)

if [ "x${percent}" != "x" ];then
        if [ $(echo "$perc_avail < $percent"|bc) = 1 ]; then
                echo "Now Avail Memory(Percent) is ${perc_avail}% < ${percent}%" >&2
                exit 1
        fi
fi

if [ "x${mega}" != "x" ];then
        if [ $(echo "$avail_mem_mb < $mega"|bc) = 1 ]; then
                echo "The Avail Memory(Mega) is ${avail_mem_mb}(M) < ${mega}(M)" >&2
                exit 1
        fi
fi


echo "OK"
exit 0
