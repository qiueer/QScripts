#!/bin/sh
# funciton : check sys load
# by qiujingqin

chk_one=""
chk_five=""
chk_fifteen=""
debug=0

usage()
{
	echo "usage: $(basename $0) [-abc]"
	echo "NAME"
	echo "	$(basename $0) - Check if OS sys-load meets requirements"
	echo "SYNOPSIS"
	echo "  -a the pass one minute sys load for check"
	echo "  -b the five minutes sys load for check"
	echo "  -c the fiftetn minutes sys load for check"
	echo "  -d debug"
	exit 1
}

while getopts ':a:b:c:d' opt
do
	case $opt in
		a) chk_one=$OPTARG ;;
		b) chk_five=$OPTARG ;;
		c) chk_fifteen=$OPTARG ;;
		d) debug=1 ;;
		*) usage;;
	esac
done

if [ $debug -eq 1 ];then
	cat /proc/loadavg
fi

# 0.00 0.01 0.05 1/352 4139
one_load=$(cat /proc/loadavg | awk '{print $1}')
five_load=$(cat /proc/loadavg | awk '{print $2}')
fifteen_load=$(cat /proc/loadavg | awk '{print $3}')

if [ "x${chk_one}" != "x" ];then
	if [ $(echo "$one_load > $chk_one"|bc) = 1 ]; then
		echo "The Passed One Minute Avg Load is ${one_load} > ${chk_one}" >&2
		exit 1
	fi
fi

if [ "x${chk_five}" != "x" ];then
	if [ $(echo "$five_load > $chk_five"|bc) = 1 ]; then
		echo "The Passed Five Minutes Avg Load is ${five_load} > ${chk_five}" >&2
		exit 1
	fi
fi

if [ "x${chk_fifteen}" != "x" ];then
	if [ $(echo "$fifteen_load > $chk_fifteen"|bc) = 1 ]; then
		echo "The Passed Fifteen Minutes Avg Load is ${fifteen_load} > ${chk_fifteen}" >&2
		exit 1
	fi
fi

echo "OK"
exit 0


