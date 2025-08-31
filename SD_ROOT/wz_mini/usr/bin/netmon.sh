#!/bin/sh

set -x

. /opt/wz_mini/wz_mini.conf
. /opt/wz_mini/etc/rc.common

wait_for_wlan_ip $(basename "$0")

sleep 30

echo "kill icamera udhcpc extra"
kill $(pgrep -f 'udhcpc -i wlan0 -H WyzeCam -p /var/run/udhcpc.pid -b')

# Specify the interfaces
MAIN="usb0"
BACKUP="wlan_old"
BOND="wlan0"

# Specify the log file
LOGFILE="/opt/wz_mini/log/netmon.log"

gateway_supervisor() {
    # Get the default gateway
    GATEWAY=$(/opt/wz_mini/tmp/.bin/ip route show default | awk '/default/ {print $3}')

    # Initialize variables
    is_interface_down=0
    attempt=0

    # Check if the gateway can be reached
    while true; do
        if /opt/wz_mini/tmp/.bin/ifconfig $MAIN | grep -q "UP"; then
            is_interface_down=0
            echo "$(date) - Interface $MAIN is up." >> $LOGFILE
        fi

        if [ $is_interface_down -eq 0 ]; then
            attempt=$((attempt+1))
            if /opt/wz_mini/tmp/.bin/ping -c 1 $GATEWAY > /dev/null 2>&1; then
                echo "$(date) - Internet connection is active." >> $LOGFILE
                attempt=0
            else
                echo "$(date) - Attempt $attempt: Internet connection is down." >> $LOGFILE
                if [ $attempt -ge 10 ]; then
                    /opt/wz_mini/tmp/.bin/ifconfig $MAIN down
                    echo "$(date) - Interface $MAIN has been brought down." >> $LOGFILE
                    is_interface_down=1
                fi
            fi
        else
            if /opt/wz_mini/tmp/.bin/ifconfig $MAIN | grep -q "UP"; then
                is_interface_down=0
                echo "$(date) - Interface $MAIN is up." >> $LOGFILE
                attempt=0
            fi
        fi

        sleep 5
    done
}

monitor_bond() {
    # Initial active interface
    active_interface=$(cat /proc/net/bonding/$BOND | grep "Currently Active Slave" | awk '{print $4}')

    while true; do
        # Current active interface
        current_interface=$(cat /proc/net/bonding/$BOND | grep "Currently Active Slave" | awk '{print $4}')

        if [ "$active_interface" != "$current_interface" ]; then
            echo "$(date) - Network interface switched from $active_interface to $current_interface." >> $LOGFILE

            # Kill any running udhcpc processes
            killall udhcpc

            # Start a new udhcpc client
            udhcpc -i wlan0 -p /var/run/udhcpc.pid -b -S

            # Update the active interface
            active_interface=$current_interface
        fi

        # Sleep for 15 seconds before checking again
        sleep 15
    done
}

# Start both functions in the background
gateway_supervisor &
monitor_bond &
