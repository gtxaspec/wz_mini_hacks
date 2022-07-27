#!/bin/sh 
##Verify the network is up before continuing
until ping -c1 www.google.com >/dev/null 2>&1; do :; done
 /opt/wz_mini/tmp/.bin/crond -b -c /opt/wz_mini/etc/crontab/
