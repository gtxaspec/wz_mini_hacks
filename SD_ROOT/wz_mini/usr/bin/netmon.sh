#!/bin/sh

. /opt/wz_mini/wz_mini.conf
. /opt/wz_mini/etc/rc.common


if [[ "$ENABLE_USB_DIRECT" == "true" ]]; then
        wait_for_wlan_ip $(basename "$0")
        gateway_supervisor $(basename "$0")
fi
