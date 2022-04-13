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

{ sleep 30; /media/mmc/wz_mini/run_mmc.sh > /media/mmc/wz_mini/log/wz_mini_hacks.log; } &

/linuxrc
