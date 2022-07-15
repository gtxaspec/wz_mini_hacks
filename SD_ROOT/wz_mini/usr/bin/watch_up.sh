#!/bin/sh

DEBUG=false

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

if [ "$DEBUG" == "true" ]; then

	if [ -L /dev/fd ]; then
		echo fd exists
	else
		echo fd does not exist, link
		ln -s /proc/self/fd /dev/fd
	fi

	LOG_FILE=/opt/wz_mini/log/watch_up.log
	exec > >(busybox tee -a ${LOG_FILE}) 2>&1
fi

set -x

event="$1"
directory="$2"
file="$3"

case "$event" in
  n)  date; if [[ "$file" == "img" ]]; then

set -x

	if [[ "$DISABLE_FW_UPGRADE" == "true" ]]; then
		#Reboot as soon as we see "img", this means an update is incoiming
		reboot
	fi

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
