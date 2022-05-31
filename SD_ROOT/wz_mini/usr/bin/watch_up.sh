#!/bin/sh

LOG_NAME=/opt/wz_mini/log/watch_up
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

event="$1"
directory="$2"
file="$3"

case "$event" in
  n)  date; if [[ "$file" == "img" ]]; then

set -x

	#hook the v2
	if cat /params/config/.product_config | grep WYZEC1-JZ; then
	while [ ! -f /tmp/Upgrade/upgraderun.sh ]
	do
	#	sed -i '/pgrep/,+4d' /tmp/Upgrade/upgraderun.sh
		sleep 0.1
	done

	else

	#t31
	while [ ! -f /tmp/Upgrade/upgraderun.sh ]
	do
		pkill -f "sh /tmp/Upgrade/upgraderun.sh"
		mv /tmp/Upgrade/upgraderun.sh /tmp/Upgrade/upgraderun.old
		echo "squashed upgraderun.sh"
		sleep 0.1
	done

		echo "start countdown"
		secs=30
		endTime=$(( $(date +%s) + secs ))
		while [ $(date +%s) -lt $endTime ]; do
				if  pgrep -f 'upgraderun.sh' > /dev/null ; then
				pkill -f "sh /tmp/Upgrade/upgraderun.sh"
				pkillexitstatus=$?
					if [ $pkillexitstatus -eq 0 ]; then
						echo "matched upgraderun.sh, killed."
						status=false
						break 1
					fi
				fi
		done
	fi

	if cat /params/config/.product_config | grep WYZEC1-JZ; then
		echo "v2 found"
		upgrade_path=$(find /tmp/Upgrade | grep upgradecp.sh)
		sed -i '/wc -c $KERNEL/,+14d' $upgrade_path
		#mv /tmp/Upgrade/upgraderun.sh /tmp/Upgrade/run_upg.sh
		#sh /tmp/Upgrade/run_upg.sh
		#/tmp/Upgrade/system_upgrade.sh
	else

		if [[ -e /tmp/Upgrade/app ]]; then
			echo "found app image, flashing"
			flashcp -v /tmp/Upgrade/app /dev/mtd3
			/opt/wz_mini/bin/busybox sync
		else
			echo "no kernel image present"
		fi

		if [[ -e /tmp/Upgrade/kernel ]]; then
			echo "found kernel image, flashing"
			flashcp -v /tmp/Upgrade/kernel /dev/mtd1
			/opt/wz_mini/bin/busybox sync
		else
			echo "no app image present"
		fi

		if [[ -e /tmp/Upgrade/rootfs ]]; then
			echo "found rootfs image, flashing"
			flashcp -v /tmp/Upgrade/rootfs /dev/mtd2
			/opt/wz_mini/bin/busybox sync
		else
			echo "no root image present"
	fi

	/opt/wz_mini/bin/busybox sync
	/opt/wz_mini/bin/busybox sync
	sleep 5
	echo reboot
	/opt/wz_mini/bin/busybox reboot

	fi

	fi;;
  *) echo "This script must be run from inotifyd";;
esac
