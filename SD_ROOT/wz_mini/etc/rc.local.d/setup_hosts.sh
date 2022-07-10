#!/bin/sh 
##Verify the network is up before continuing
until ping -c1 www.google.com >/dev/null 2>&1; do :; done
FILE=/tmp/test_hosts
if test -f "$FILE"; then
#We just need to clear and re generate. rebuilding the file is kinda pointless and script may be used on long running cameras.
true > /tmp/test_hosts
echo 127.0.0.1 localhost >>/tmp/test_hosts
dns=$(cat /etc/resolv.conf | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
server=$(nslookup c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com $dns | awk -F': ' 'NF==2 { print $2 } ' | head -1)
echo $server c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com >>/tmp/test_hosts
else
#generate the file and mount
touch /tmp/test_hosts
echo 127.0.0.1 localhost >>/tmp/test_hosts
dns=$(cat /etc/resolv.conf | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
server=$(nslookup c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com $dns | awk -F': ' 'NF==2 { print $2 } ' | head -1)
echo $server c1ybkrkbr1j10x.credentials.iot.us-west-2.amazonaws.com >>/tmp/test_hosts
mount --bind /tmp/test_hosts /etc/hosts
fi
