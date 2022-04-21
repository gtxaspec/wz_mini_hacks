#!/bin/sh

event="$1"
directory="$2"
file="$3"

case "$event" in
  n) 	if [[ "$file" == "upgraderun.sh" ]]; then
		pkill -f "sh /tmp/Upgrade/upgraderun.sh"
		mv /tmp/Upgrade/upgraderun.sh /tmp/Upgrade/upgraderun.old
		echo "squashed upgraderun.sh"

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
	/opt/wz_mini/bin/busybox reboot

	fi;;
  *) echo "This script must be run from inotifyd";;
esac
