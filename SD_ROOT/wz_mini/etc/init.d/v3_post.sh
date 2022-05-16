#!/bin/sh

##THIS FILE IS CALLED BY rcS, EXECUTED BEFORE app_init.sh IS RUN.

exec 1> /opt/wz_mini/log/v3_post.log 2>&1

echo "welcome to v3_post.sh"
echo "PID $$"

set -x

echo "v3_post.sh exec"


if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_HI_RES_ENABLED\=") == "RTSP_HI_RES_ENABLED\=\"true\"" ]] ||  [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_LOW_RES_ENABLED\=") == "RTSP_LOW_RES_ENABLED\=\"true\"" ]] && ! [[ -e /tmp/dbgflag ]]; then
	if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_LOW_RES_ENABLED\=") == "RTSP_LOW_RES_ENABLED\=\"true\"" ]] && [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_HI_RES_ENABLED\=") == "RTSP_HI_RES_ENABLED\=\"true\"" ]]; then
	        echo "load video loopback driver at video1 video2"
	        insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=1,2
	elif [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_LOW_RES_ENABLED\=") == "RTSP_LOW_RES_ENABLED\=\"true\"" ]]; then
	        echo "load video loopback driver at video2"
	        insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=2
	elif [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_HI_RES_ENABLED\=") == "RTSP_HI_RES_ENABLED\=\"true\"" ]]; then
	        echo "load video loopback driver at video1"
	        insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=1
	fi

        cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
        mount -o ro,bind /opt/wz_mini/usr/bin/iCamera /system/bin/iCamera
fi

##LIBRARY DEBUG
#cp /opt/wz_mini/lib/uClibc.tar /tmp
#tar -xf /tmp/uClibc.tar -C /tmp
#mount --bind /tmp/lib /lib
#cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
#mount -o ro,bind /opt/wz_mini/usr/bin/iCamera-dbg /system/bin/iCamera
