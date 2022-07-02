#!/bin/sh

### This file is called by /etc/init.d/rcS, and is run before app_init.sh

LOG_NAME=/opt/wz_mini/log/wz_post
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

set -x

if [ -e /tmp/dbgflag ];then
	echo "debug mode, disabled"
	exit 0
fi

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

echo "welcome to wz_post.sh"
echo "PID $$"

if [ -d /opt/.wz_backup ]; then
        echo "backup directory missing"
else
	echo "creating backup directory"
        mkdir /opt/.wz_backup
fi

if [ -f /opt/wz_mini/tmp/.T31 ]; then
        echo "T31 platform backup"
        if [ -d /opt/.wz_backup/configs ]; then
                echo "configs backup directory present, not backing up again"
        else
                echo "backup /configs"
                cp -R /configs/ /opt/.wz_backup/
        fi
elif [ -f /opt/wz_mini/tmp/.T20 ]; then
        echo "T20 platform backup"
        if [ -d /opt/.wz_backup/configs ]; then
                echo "configs backup directory present, not backing up again"
        else
                echo "backup /configs"
                cp -R /configs/ /opt/.wz_backup/
        fi

        if [ -d /opt/.wz_backup/params ]; then
                echo "configs backup directory present, not backing up again"
        else
                echo "backup /params"
                cp -R /params/ /opt/.wz_backup/
        fi
fi

if [[ "$ENABLE_SWAP" == "true" ]] && [[ -e /opt/wz_mini/swap ]]; then
        echo "swap file found, enable"
        swapon /opt/wz_mini/swap
else
        echo "swap file missing"
fi

if [ -d /lib/modules ]; then
	echo "mount kernel modules"
	mount --bind /opt/wz_mini/lib/modules /lib/modules
fi

## REPLACE STOCK MODULES

if [[ "$ENABLE_RTL8189FS_DRIVER" == "true" ]] || [[ "$ENABLE_RTL8189FS_DRIVER" == "" ]]; then
        echo "Enable 8189fs"
        if [ -f /opt/wz_mini/tmp/.WYZEC1-JZ ]; then
                sed -i 's/\/driver\/rtl8189ftv.ko/\/opt\/wz_mini\/lib\/modules\/3.10.14\/extra\/8189fs.ko rtw_power_mgnt=0 rtw_enusbss=0 rtw_drv_log_level=3/g' /opt/wz_mini/tmp/.storage/app_init.sh
        elif [ -f /opt/wz_mini/tmp/.WYZECP1_JEF ]; then
                sed -i 's/insmod \/driver\/8189es.ko/insmod \/opt\/wz_mini\/lib\/modules\/3.10.14\/extra\/8189es.ko rtw_power_mgnt=0 rtw_enusbss=0 rtw_drv_log_level=3/g' /opt/wz_mini/tmp/.storage/app_init.sh
        elif [ -f /opt/wz_mini/tmp/.WYZE_CAKP2JFUS ]; then
                sed  -i 's/\/system\/driver\/rtl8189ftv.ko/\/opt\/wz_mini\/lib\/modules\/3.10.14\_\_isvp_swan_1.0\_\_\/extra\/8189fs.ko rtw_power_mgnt=0 rtw_enusbss=0 rtw_drv_log_level=4/g'  /opt/wz_mini/tmp/.storage/app_init.sh
        fi
fi

if [[ "$ENABLE_ATBM603X_DRIVER" == "true" ]] || [[ "$ENABLE_ATBM603X_DRIVER" == "" ]]; then
	echo "Enable atbm603x_wifi_sdio"
	if [ -f /opt/wz_mini/tmp/.T31 ]; then
		sed -i 's/\/system\/driver\/atbm603x_wifi_sdio.ko/\/opt\/wz_mini\/lib\/modules\/3.10.14\_\_isvp_swan_1.0\_\_\/extra\/atbm603x_wifi_sdio.ko/g' /opt/wz_mini/tmp/.storage/app_init.sh
	fi
fi

##RTSP SERVER INIT

if [[ "$RTSP_HI_RES_ENABLED" == "true" ]] ||  [[ "$RTSP_LOW_RES_ENABLED" == "true" ]] && ! [[ -e /tmp/dbgflag ]]; then
	if [[ "$RTSP_LOW_RES_ENABLED" == "true" ]] && [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		        echo "load video loopback driver at video6 video7"
		        insmod /opt/wz_mini/lib/modules/3.10.14/extra/v4l2loopback_V2.ko video_nr=6,7
		else
		        echo "load video loopback driver at video1 video2"
		        insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/v4l2loopback.ko video_nr=1,2
		fi
	elif [[ "$RTSP_LOW_RES_ENABLED" == "true" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		        echo "load video loopback driver at video7"
		        insmod /opt/wz_mini/lib/modules/3.10.14/extra/v4l2loopback_V2.ko video_nr=7
		else
		        echo "load video loopback driver at video2"
	        	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/v4l2loopback.ko video_nr=2
		fi
	elif [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		        echo "load video loopback driver at video6"
		        insmod /opt/wz_mini/lib/modules/3.10.14/extra/v4l2loopback_V2.ko video_nr=6
		else
		        echo "load video loopback driver at video1"
		        insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/v4l2loopback.ko video_nr=1
		fi
	fi
	echo "set path for iCamera"
	sed -i 's/\/system\/bin\/iCamera/\/opt\/wz_mini\/usr\/bin\/iCamera/g' /opt/wz_mini/tmp/.storage/app_init.sh
fi

/opt/wz_mini/etc/init.d/wz_user.sh &

if [[ "$DISABLE_MOTOR" == "true" ]]; then
	echo "Motor Disabled"
	touch /opt/wz_mini/tmp/.ms
fi

##LIBRARY DEBUG
#cp /opt/wz_mini/lib/uClibc.tar /tmp
#tar -xf /tmp/uClibc.tar -C /tmp
#mount --bind /tmp/lib /lib
#cp /system/bin/iCamera /opt/wz_mini/tmp/.storage/
#mount -o ro,bind /opt/wz_mini/usr/bin/iCamera-dbg /system/bin/iCamera
