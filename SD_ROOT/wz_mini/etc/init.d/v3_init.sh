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

mount -t tmpfs /tmp
cp /opt/wz_mini/etc/shadow /tmp/.shadow
mount --bind /tmp/.shadow /etc/shadow
chmod 400 /etc/shadow

if [[ -f /opt/wz_mini/swap.gz ]]; then
	echo "swap archive present, extracting"
        gzip -d /opt/wz_mini/swap.gz
        mkswap /opt/wz_mini/swap
	sync;echo 3 > /proc/sys/vm/drop_caches;free
else
	echo "swap archive not present, not extracting"
fi

{ sleep 30; /media/mmc/wz_mini/run_mmc.sh 22> /media/mmc/wz_mini/log/wz_mini_hacks.log; } &

/linuxrc
