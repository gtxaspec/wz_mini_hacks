#!/bin/sh

set -x

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
