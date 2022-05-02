#!/bin/sh
###
###DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING
###

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

sleep 2

set -x

#WCV3 GPIO
GPIO=63

#Check model, change GPIO is HL_PAN2
mount -t jffs2 /dev/mtdblock6 /configs
if [[ $(cat /configs/.product_config  | grep PRODUCT_MODEL) == "PRODUCT_MODEL=HL_PAN2" ]]; then
umount /configs
GPIO=7
fi

if [[ -e /opt/wz_mini/etc/.first_boot ]]; then
        echo "first boot already completed"
else
	echo "first boot, initializing"
        insmod /opt/wz_mini/lib/modules/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
        /opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/init.wav 50
        rmmod audio
        touch /opt/wz_mini/etc/.first_boot
fi

mount --bind /opt/wz_mini/etc/inittab /etc/inittab

echo "bind /etc/profile for local/ssh shells"
mount --bind /opt/wz_mini/etc/profile /etc/profile

echo "mounting tempfs for workspace"
mount -t tmpfs /tmp

echo "mount system to replace factorycheck with dummy, to prevent bind unmount"
mount /dev/mtdblock3 /system
mount --bind /opt/wz_mini/bin/factorycheck /system/bin/factorycheck
touch /tmp/usrflag

echo "replace stock fstab"
mount --bind /opt/wz_mini/etc/fstab /etc/fstab

echo "mount workplace dir"
mount -t tmpfs /opt/wz_mini/tmp

echo "install busybox applets"
mkdir /opt/wz_mini/tmp/.bin
/opt/wz_mini/bin/busybox --install -s /opt/wz_mini/tmp/.bin

echo "create workspace directory"
mkdir /opt/wz_mini/tmp/.storage

echo "copy stock rcS"
cp /etc/init.d/rcS /opt/wz_mini/tmp/.storage/rcS

echo "add v3_post inject to stock rcS"
sed -i '/^".*/aset -x' /opt/wz_mini/tmp/.storage/rcS
sed -i '/^# Mount configs.*/i/opt/wz_mini/etc/init.d/v3_post.sh\n' /opt/wz_mini/tmp/.storage/rcS

sed -i '/sbin:/s/$/:\/opt\/wz_mini\/bin/' /opt/wz_mini/tmp/.storage/rcS
sed -i '/system\/\lib/s/$/:\/opt\/wz_mini\/lib/' /opt/wz_mini/tmp/.storage/rcS

#Custom PATH hooks
#sed -i '/^# Run init script.*/i#Hook Library PATH here\nexport LD_LIBRARY_PATH=/tmp/test/lib:$LD_LIBRARY_PATH\n' /opt/wz_mini/tmp/.storage/rcS
#sed -i '/^# Run init script.*/i#Hook system PATH here\nexport PATH=/tmp/test/bin:$PATH\n' /opt/wz_mini/tmp/.storage/rcS

echo "replace stock password"
cp /opt/wz_mini/etc/shadow /opt/wz_mini/tmp/.storage/shadow
mount --bind /opt/wz_mini/tmp/.storage/shadow /etc/shadow
chmod 400 /etc/shadow

if [[ -e /opt/wz_mini/swap.gz ]]; then
	insmod /opt/wz_mini/lib/modules/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
	/opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/swap.wav 50
	rmmod audio
	echo "swap archive present, extracting"
        gzip -d /opt/wz_mini/swap.gz
        mkswap /opt/wz_mini/swap
	sync;echo 3 > /proc/sys/vm/drop_caches;free
else
	echo "swap archive not present, not extracting"
fi

if [[ -d /opt/wz_mini/usr/share/terminfo ]]; then
	echo "terminfo already present"
else
	echo "terminfo not present, extract"
	tar xf /opt/wz_mini/usr/share/terminfo.tar -C /opt/wz_mini/usr/share/

fi

echo "Run dropbear ssh server"
/opt/wz_mini/bin/dropbear -R -s -g

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "DEBUG_ENABLED\=") == "DEBUG_ENABLED\=\"true\"" ]]; then
        sed -i '/app_init.sh/,+3d' /opt/wz_mini/tmp/.storage/rcS
        sed -i '/^# Run init/i/bin/sh /etc/profile' /opt/wz_mini/tmp/.storage/rcS
	touch /tmp/dbgflag
fi

if ! [[ -e /tmp/dbgflag ]]; then
	{ sleep 30; /media/mmc/wz_mini/run_mmc.sh 2> /media/mmc/wz_mini/log/wz_mini_hacks.log; } &
else
	echo "debug enabled, ignore run_mmc.sh"
fi


/linuxrc
