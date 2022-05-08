#!/bin/sh

echo 'wpa_state=COMPLETED'
echo ip_address=`ifconfig wlan0 | awk '/inet / {print $2}' | awk -F: '{print $2}'`
