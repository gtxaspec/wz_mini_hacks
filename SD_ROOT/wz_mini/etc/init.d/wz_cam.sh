#!/bin/sh

set -x

cp /opt/wz_mini/etc/uvc.config /opt/wz_mini/usr/bin/uvc.config

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "WEB_CAM_FPS_RATE\=") != "" ]]; then
WEB_CAM_FPS_RATE=$(cat /opt/wz_mini/run_mmc.sh | grep "WEB_CAM_FPS_RATE\=" | cut -d'"' -f 2)
echo RATE IS $WEB_CAM_FPS_RATE
sed -i "s/fps_num         :30/fps_num         :$WEB_CAM_FPS_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
fi

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "WEB_CAM_BIT_RATE\=") != "" ]]; then
WEB_CAM_BIT_RATE=$(cat /opt/wz_mini/run_mmc.sh | grep "WEB_CAM_BIT_RATE\=" | cut -d'"' -f 2)
sed -i "s/bitrate         :8000/bitrate         :$WEB_CAM_BIT_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
fi

exec 1> /opt/wz_mini/log/wz_cam.log 2>&1

mount --bind /opt/wz_mini/usr/bin /system/bin
insmod /system/driver/avpu.ko
insmod /system/driver/tx-isp-t31.ko isp_clk=220000000
insmod /system/driver/sensor_gc2053_t31.ko
insmod /system/driver/audio.ko
insmod /opt/wz_mini/lib/modules/libcomposite.ko
insmod /opt/wz_mini/lib/modules/videobuf2-vmalloc.ko
insmod /opt/wz_mini/lib/modules/usbcamera.ko

cd /system/bin/
/system/bin/ucamera &

#Set dwc2 ID_PIN driver memory
devmem 0x13500000 32 0x001100cc
devmem 0x10000040 32 0x0b000096
#wipe the bits to set the ID_PIN
devmem 0x10000040 32 0x0b000FFF
