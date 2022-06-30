#!/bin/sh 
##Verify the network is up before continuing
until ping -c1 www.google.com >/dev/null 2>&1; do :; done
 
/opt/wz_mini/tmp/.bin/crond -b -c /opt/wz_mini/etc/crontab/

touch /tmp/test_hosts
echo 127.0.0.1 localhost >>/tmp/test_hosts
dns=$(cat /etc/resolv.conf | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
server=$(nslookup c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com $dns | awk -F': ' 'NF==2 { print $2 } ' | head -1)
echo $server c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com >>/tmp/test_hosts
mount --bind /tmp/test_hosts /etc/hosts
