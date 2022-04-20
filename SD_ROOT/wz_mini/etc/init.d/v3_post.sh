#!/bin/sh

set -x

echo "v3_post.sh"

sed -i '/sbin:/s/$/:\/opt\/wz_mini\/bin/' /opt/wz_mini/tmp/.storage/rcS
sed -i '/system\/\lib/s/$/:\/opt\/wz_mini\/lib/' /opt/wz_mini/tmp/.storage/rcS

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_ENABLED\=") == "RTSP_ENABLED\=\"true\"" ]] && ! [[ -e /tmp/dbgflag ]]; then
        cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
        mount -o ro,bind /opt/wz_mini/usr/bin/iCamera /system/bin/iCamera
        echo "load video loopback driver at video1"
        insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=1
fi

