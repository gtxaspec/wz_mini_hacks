#!/bin/sh

LOG_NAME=/opt/wz_mini/log/wz_cam
if [[ -e $LOG_NAME.log || -L $LOG_NAME.log ]] ; then
    i=0
    while [[ -e $LOG_NAME.log.$i || -L $LOG_NAME.log.$i ]] ; do
        let i++
    done
        mv $LOG_NAME.log $LOG_NAME.log.$i
    LOG_NAME=$LOG_NAME
fi
touch -- "$LOG_NAME".log
exec 1> $LOG_NAME.log 2>&1

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

set -x

echo "welcome to wz_cam.sh"
echo "PID $$"

        if [ -f /opt/wz_mini/tmp/.T31 ]; then

	cp /opt/wz_mini/etc/uvc.config /opt/wz_mini/usr/bin/uvc.config

	if [[ "WEB_CAM_FPS_RATE" != "" ]]; then
	sed -i "s/fps_num         :30/fps_num         :$WEB_CAM_FPS_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
	fi

	if [[ "WEB_CAM_BIT_RATE" != "" ]]; then
	sed -i "s/bitrate         :8000/bitrate         :$WEB_CAM_BIT_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
	fi

	echo 1 > /proc/sys/vm/overcommit_memory

	mount --bind /opt/wz_mini/usr/bin /system/bin
	insmod /system/driver/avpu.ko
	insmod /system/driver/tx-isp-t31.ko isp_clk=220000000
	insmod /system/driver/sensor_gc2053_t31.ko
	insmod /system/driver/audio.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/libcomposite.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/videobuf2-vmalloc.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/usbcamera.ko

	cd /system/bin/
	/system/bin/ucamera &

	sleep 1

	#Set dwc2 ID_PIN driver memory
	devmem 0x13500000 32 0x001100cc
	devmem 0x10000040 32 0x0b000096
	#wipe the bits to set the ID_PIN
	devmem 0x10000040 32 0x0b000FFF

	sleep 1

	cd /sys/class/gpio
	echo 39 > export
	cd gpio39
	echo out > direction
	echo 0 > active_low
	echo 0 > value

	/opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/binbin_v3.wav 30

else

	cp /opt/wz_mini/etc/uvc_v2.config /opt/wz_mini/usr/bin/uvc.config

	if [[ "WEB_CAM_FPS_RATE" != "" ]]; then
	sed -i "s/fps_num         :30/fps_num         :$WEB_CAM_FPS_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
	fi

	if [[ "WEB_CAM_BIT_RATE" != "" ]]; then
	sed -i "s/bitrate         :8000/bitrate         :$WEB_CAM_BIT_RATE/" "/opt/wz_mini/usr/bin/uvc.config"
	fi

	mount --bind /opt/wz_mini/usr/bin /system/bin

	insmod /driver/tx-isp.ko isp_clk=100000000
	insmod /driver/exfat.ko
	insmod /driver/sample_motor.ko
	insmod /opt/wz_mini/lib/modules/3.10.14/extra/audio_webcam.ko
	insmod /driver/sinfo.ko
	insmod /driver/sample_pwm_core.ko
	insmod /driver/sample_pwm_hal.ko

	insmod /opt/wz_mini/lib/modules/3.10.14/extra/libcomposite.ko
	insmod /opt/wz_mini/lib/modules/3.10.14/extra/videobuf2-vmalloc.ko
	insmod /opt/wz_mini/lib/modules/3.10.14/extra/usbcamera.ko

	/opt/wz_mini/usr/bin/getSensorType
	/opt/wz_mini/usr/bin/ucamera_v2 &

	devmem 0x10000040 32 0x0b000096
	devmem 0x10000040 32 0x0b800096
	devmem 0x13500000 32 0x001100cc

	sleep 1

	echo 38 > /sys/class/gpio/export
	echo 39 > /sys/class/gpio/export

	echo out > /sys/class/gpio/gpio38/direction
	echo out > /sys/class/gpio/gpio39/direction

	/opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/binbin_v3.wav 30

fi
