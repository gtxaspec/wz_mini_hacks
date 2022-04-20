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

set -x

echo "mounting tempfs for workspace"
mount -t tmpfs /tmp
mount -t tmpfs /run

echo "create workspace directory"
mkdir /run/.storage

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "RTSP_ENABLED\=") == "RTSP_ENABLED\=\"true\"" ]]; then
cp /etc/init.d/rcS /run/.storage/rcS
sed -i '/^".*/aset -x' /run/.storage/rcS
sed -i '/^# Mount configs.*/i cp /system/bin/iCamera /run/.storage/\nmount -o ro,bind /opt/wz_mini/usr/bin/iCamera /system/bin/iCamera\n tail -f /system/bin/iCamera > /dev/null 2>&1 &' /run/.storage/rcS
sed -i '/sbin:/s/$/:\/opt\/wz_mini\/bin/' /run/.storage/rcS
sed -i '/system\/\lib/s/$/:\/opt\/wz_mini\/lib/' /run/.storage/rcS
mount --bind /run/.storage/rcS /etc/init.d/rcS
echo "load video loopback driver at video1"
insmod /opt/wz_mini/lib/modules/v4l2loopback.ko video_nr=1
fi

if [[ $(cat /opt/wz_mini/run_mmc.sh | grep "DEBUG_ENABLED\=") == "DEBUG_ENABLED\=\"true\"" ]]; then
cp /etc/init.d/rcS /run/.storage/rcS
sed -i '/app_init.sh/,+2d' /run/.storage/rcS
sed -i '/^# Run init/i/bin/sh /etc/profile' /run/.storage/rcS
mount --bind /run/.storage/rcS /etc/init.d/rcS
fi

echo "replace stock password"
cp /opt/wz_mini/etc/shadow /run/.storage/shadow
mount --bind /run/.storage/shadow /etc/shadow
chmod 400 /etc/shadow

echo "bind /etc/profile for local/ssh shells"
mount --bind /opt/wz_mini/etc/profile /etc/profile

if [[ -f /opt/wz_mini/swap.gz ]]; then
	echo "swap archive present, extracting"
        gzip -d /opt/wz_mini/swap.gz
        mkswap /opt/wz_mini/swap
	sync;echo 3 > /proc/sys/vm/drop_caches;free
else
	echo "swap archive not present, not extracting"
fi

echo "mount configs partition for dropbear"
mount -t jffs2 /dev/mtdblock6 /configs

if [[ -d /configs/.ssh ]]; then
        echo "dropbear ssh config dir present"
	umount /configs
else
        echo "dropbear ssh config dir not present, creating"
        mkdir /configs/.ssh
	umount /configs
fi

echo "Run dropbear ssh server"
/opt/wz_mini/bin/dropbearmulti dropbear -R -m

{ sleep 30; /media/mmc/wz_mini/run_mmc.sh 2> /media/mmc/wz_mini/log/wz_mini_hacks.log; } &

/linuxrc
