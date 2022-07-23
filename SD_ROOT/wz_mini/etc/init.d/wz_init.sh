#!/bin/sh

###This file is run by switch_root, from the initramfs in the kernel.
LOG_NAME=/opt/wz_mini/log/wz_init
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

echo "welcome to wz_init.sh"
echo "PID $$"

echo '
 __          ________  __  __ _____ _   _ _____
 \ \        / |___  / |  \/  |_   _| \ | |_   _|
  \ \  /\  / /   / /  | \  / | | | |  \| | | |
   \ \/  \/ /   / /   | |\/| | | | | . ` | | |
    \  /\  /   / /__  | |  | |_| |_| |\  |_| |_
     \/  \/   /_____| |_|  |_|_____|_| \_|_____|
                  ______
                 |______|
'

set -x

echo "replace stock busybox"
mount --bind /opt/wz_mini/bin/busybox /bin/busybox

echo "replace stock fstab"
mount --bind /opt/wz_mini/etc/fstab /etc/fstab

echo "mount wz_mini tmpfs"
mount -t tmpfs /opt/wz_mini/tmp

echo "install busybox applets"
mkdir /opt/wz_mini/tmp/.bin
/opt/wz_mini/bin/busybox --install -s /opt/wz_mini/tmp/.bin

##DETECT CAMERA MODEL & PLATFORM TYPE
#V2=WYZEC1-JZ
#PANv1=WYZECP1_JEF
#PANv2=HL_PAN2
#V3=WYZE_CAKP2JFUS
#DB3=WYZEDB3
#V3C=ATOM_CamV3C

#mtdblock9 only exists on the T20 platform, indicating V2 or PANv1
if [ -b /dev/mtdblock9 ]; then
        mkdir /opt/wz_mini/tmp/params
        mount -t jffs2 /dev/mtdblock9 /opt/wz_mini/tmp/params
        touch /opt/wz_mini/tmp/.$(cat /opt/wz_mini/tmp/params/config/.product_config | grep PRODUCT_MODEL | sed -e 's#.*=\(\)#\1#')
        touch /opt/wz_mini/tmp/.T20
        umount /opt/wz_mini/tmp/params
        rm -rf /opt/wz_mini/tmp/params
elif [ -b /dev/mtdblock6 ]; then
        mkdir /opt/wz_mini/tmp/configs
        mount -t jffs2 /dev/mtdblock6 /opt/wz_mini/tmp/configs
        touch /opt/wz_mini/tmp/.$(cat /opt/wz_mini/tmp/configs/.product_config | grep PRODUCT_MODEL | sed -e 's#.*=\(\)#\1#')
        touch /opt/wz_mini/tmp/.T31
        umount /opt/wz_mini/tmp/configs
        rm -rf /opt/wz_mini/tmp/configs
fi

#Set the correct GPIO for the audio driver (T31 only)
if [ -f /opt/wz_mini/tmp/.HL_PAN2 ]; then
        GPIO=7
elif [ -f /opt/wz_mini/tmp/.WYZE_CAKP2JFUS ]; then
        GPIO=63
fi

if [ -e /opt/wz_mini/etc/.first_boot ]; then
        echo "first boot already completed"
else
	echo "first boot, initializing"
	if [ -f /opt/wz_mini/tmp/.T20 ]; then
		#May need different gpio for PANv1
		#We don't rmmod this module, as it is marked [permanent] by the kernel on T20
		insmod /opt/wz_mini/lib/modules/3.10.14/extra/audio.ko sign_mode=0
        	LD_LIBRARY_PATH='/opt/wz_mini/lib' /opt/wz_mini/bin/audioplay_t20 /opt/wz_mini/usr/share/audio/init_v2.wav $AUDIO_PROMPT_VOLUME
	else
	        insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
        	/opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/init.wav $AUDIO_PROMPT_VOLUME
        	rmmod audio
	fi
fi


if [ -f /opt/wz_mini/etc/.first_boot ]; then
	echo "Not first_boot"
else
	echo "Set first_boot"
	touch /opt/wz_mini/etc/.first_boot
fi

echo "replace stock inittab"
mount --bind /opt/wz_mini/etc/inittab /etc/inittab

echo "bind /etc/profile for local/ssh shells"
mount --bind /opt/wz_mini/etc/profile /etc/profile

echo "mounting global tmpfs"
mount -t tmpfs /tmp

echo "mount system to replace factorycheck with dummy, to prevent bind unmount"
if [ -f /opt/wz_mini/tmp/.T31 ]; then
	mount /dev/mtdblock3 /system
	mount --bind /opt/wz_mini/bin/factorycheck /system/bin/factorycheck
fi

touch /tmp/usrflag

echo "create workspace directory"
mkdir /opt/wz_mini/tmp/.storage

echo "copy stock rcS"
cp /etc/init.d/rcS /opt/wz_mini/tmp/.storage/rcS

echo "add wz_post inject to stock rcS"
sed -i '/^".*/aset -x' /opt/wz_mini/tmp/.storage/rcS
sed -i '/^# Run init script.*/i/opt/wz_mini/etc/init.d/wz_post.sh\n' /opt/wz_mini/tmp/.storage/rcS

sed -i '/sbin:/s/$/:\/opt\/wz_mini\/bin/' /opt/wz_mini/tmp/.storage/rcS
sed -i '/system\/\lib/s/$/:\/opt\/wz_mini\/lib/' /opt/wz_mini/tmp/.storage/rcS

#Custom PATH hooks
#sed -i '/^# Run init script.*/i#Hook Library PATH here\nexport LD_LIBRARY_PATH=/tmp/test/lib:$LD_LIBRARY_PATH\n' /opt/wz_mini/tmp/.storage/rcS
#sed -i '/^# Run init script.*/i#Hook system PATH here\nexport PATH=/tmp/test/bin:$PATH\n' /opt/wz_mini/tmp/.storage/rcS

if [ -f /opt/wz_mini/tmp/.T20 ]; then
        mount -t jffs2 /dev/mtdblock4 /system
fi

#Check for Car FW
if [ -f /opt/wz_mini/tmp/.WYZEC1-JZ ]; then
        if cat /system/bin/app.ver | grep 4.55; then
                touch /opt/wz_mini/tmp/.CAR
        fi
fi

if [[ "$DISABLE_WZ_WIFI" == "true"  ]]; then
    echo "Copy and modify factory app_init.sh"
    sed -r 's/.sys.bus.+mmc.+devices.+vendor/\/sys\/class\/net\/wlan0\/address/g' /system/init/app_init.sh > /opt/wz_mini/tmp/.storage/app_init.sh
    chmod +x /opt/wz_mini/tmp/.storage/app_init.sh
else
    echo "Copy factory app_init.sh"
    cp /system/init/app_init.sh /opt/wz_mini/tmp/.storage/app_init.sh
fi

echo "Replace factory app_init.sh path"
sed -i '/\/system\/init\/app_init.sh/,+4d' /opt/wz_mini/tmp/.storage/rcS
sed -i '/Run init script.*/a /opt/wz_mini/tmp/.storage/app_init.sh\n' /opt/wz_mini/tmp/.storage/rcS
sed -i '/\/syst em\/init\/app_init.sh/,+2d' /opt/wz_mini/tmp/.storage/rcS

echo "replace stock password"
cp /opt/wz_mini/etc/shadow /opt/wz_mini/tmp/.storage/shadow

if [[ "$DEBUG_PASSWORD" == "true" ]]; then
sed -i 's/:[^:]*/:/' /opt/wz_mini/tmp/.storage/shadow
fi

mount --bind /opt/wz_mini/tmp/.storage/shadow /etc/shadow
chmod 400 /etc/shadow

if [[ -e /opt/wz_mini/swap.gz ]]; then
        if [ -f /opt/wz_mini/tmp/.T20 ]; then
        	LD_LIBRARY_PATH='/opt/wz_mini/lib' /opt/wz_mini/bin/audioplay_t20 /opt/wz_mini/usr/share/audio/swap_v2.wav $AUDIO_PROMPT_VOLUME
	else
		insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
		/opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/swap.wav $AUDIO_PROMPT_VOLUME
		rmmod audio
	fi
	echo "swap archive present, extracting"
        gzip -d /opt/wz_mini/swap.gz
        mkswap /opt/wz_mini/swap
	sync;echo 3 > /proc/sys/vm/drop_caches
else
	echo "swap archive missing, not extracting"
fi

if [ -d /opt/wz_mini/usr/share/terminfo ]; then
	echo "terminfo already present"
else
	echo "terminfo not present, extract"
	tar xf /opt/wz_mini/usr/share/terminfo.tar -C /opt/wz_mini/usr/share/

fi

echo "Run dropbear ssh server"
/opt/wz_mini/bin/dropbear -R -s -g

if [[ "$DEBUG_ENABLED" == "true" ]]; then
        sed -i '/app_init.sh/,+4d' /opt/wz_mini/tmp/.storage/rcS
        sed -i '/^# Run init/i/bin/sh /etc/profile' /opt/wz_mini/tmp/.storage/rcS
	touch /tmp/dbgflag

elif [[ "$WEB_CAM_ENABLE" == "true" ]]; then
        sed -i '/app_init.sh/,+4d' /opt/wz_mini/tmp/.storage/rcS
        sed -i '/^# Run init/i/opt/wz_mini/etc/init.d/wz_cam.sh &' /opt/wz_mini/tmp/.storage/rcS
	touch /tmp/dbgflag

elif [[ -d /opt/Upgrade ]]; then
        sed -i '/app_init.sh/,+4d' /opt/wz_mini/tmp/.storage/rcS
        sed -i '/^# Run init/i/bin/sh /etc/profile' /opt/wz_mini/tmp/.storage/rcS
	sed -i '/^# Mount configs.*/i/opt/wz_mini/bin/upgrade-run.sh &\n' /opt/wz_mini/tmp/.storage/rcS
	touch /tmp/dbgflag
fi

/linuxrc
