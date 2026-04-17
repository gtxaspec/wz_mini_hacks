#!/bin/sh

#init.d/ = early boot, before inittab is run
#rc.d/ = runs after /linuxrc, but before app_init.sh
#network.d/ runs after app_init.sh, and after wlan hw is ready
#rc.local.d/ = runs after app_init.sh and network has acquired an address

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

##### SD card filesystem check #####
# Must run before any init.d script accesses the card.
# wz_init.sh is already loaded in shell memory, so unmounting /opt/wz_mini is safe here.
# The busybox binary is staged to /tmp (RAM) before unmounting so it remains executable.
# NOTE: We intentionally do NOT source wz_mini.conf here — S00config (dos2unix) has not run
# yet, so Windows line endings could corrupt sourced variable values. Use sed|grep instead.
_FSCK_SKIP=0
if sed 's/\r//' /opt/wz_mini/wz_mini.conf 2>/dev/null | grep -q 'ENABLE_FSCK_ON_BOOT="false"'; then
	echo "fsck on boot disabled, skipping"
else
	SD_DEV=$(awk '$2 == "/opt/wz_mini" {print $1; exit}' /proc/mounts)
	if [ -z "$SD_DEV" ]; then
		echo "Could not detect SD card device, skipping fsck"
	elif cp /opt/wz_mini/bin/busybox /tmp/wz_fsck_bb 2>/dev/null; then
		echo "Running dosfsck on $SD_DEV"
		umount -l /opt/wz_mini
		/tmp/wz_fsck_bb dosfsck -a "$SD_DEV"
		FSCK_RC=$?
		if mount "$SD_DEV" /opt/wz_mini; then
			rm -f /tmp/wz_fsck_bb
			[ "$FSCK_RC" -eq 0 ] && echo "dosfsck completed successfully" || echo "dosfsck completed with exit code: $FSCK_RC"
		else
			echo "CRITICAL: Failed to remount SD card at /opt/wz_mini — halting init.d boot sequence"
			_FSCK_SKIP=1
		fi
	else
		echo "Could not stage fsck tool to /tmp, skipping fsck"
	fi
fi

# Start all init scripts in /etc/init.d
# executing them in numerical order.
#
if [ "$_FSCK_SKIP" -eq 1 ]; then
	echo "Skipping init.d boot sequence due to SD card remount failure"
else
for i in /opt/wz_mini/etc/init.d/S??* ;do

     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     case "$i" in
        *.sh)
            # Source shell script for speed.
            (
                trap - INT QUIT TSTP
                set start
                . $i
            )
            ;;
        *)
            # No sh extension, so fork subprocess.
            $i start
            ;;
    esac
done
fi

/linuxrc
