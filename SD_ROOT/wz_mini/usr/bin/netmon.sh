#!/bin/sh

. /opt/wz_mini/wz_mini.conf
. /opt/wz_mini/etc/rc.common

if [[ "$ENABLE_USB_DIRECT" == "true" ]]; then
	wait_for_wlan_ip $(basename "$0")
	sleep 5
	gateway_supervisor $(basename "$0") &
fi

echo "kill udhcpc extra"
kill $(pgrep -f 'udhcpc -i wlan0 -H WyzeCam')

