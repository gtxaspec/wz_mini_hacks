#!/bin/sh

##THIS FILE IS CALLED BY rcS, EXECUTED BEFORE app_init.sh IS RUN.

set -x

echo "v3_post.sh exec"

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_ENABLED\=") == "RTSP_ENABLED\=\"true\"" ]] && ! [[ -e /tmp/dbgflag ]]; then
        cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
        mount -o ro,bind /opt/wz_mini/usr/bin/iCamera /system/bin/iCamera
        echo "load video loopback driver at video1"
        insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=1
fi

##LIBRARY DEBUG
#cp /opt/wz_mini/lib/uClibc.tar /tmp
#tar -xf /tmp/uClibc.tar -C /tmp
#mount --bind /tmp/lib /lib
#cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
#mount -o ro,bind /opt/wz_mini/usr/bin/iCamera-dbg /system/bin/iCamera
