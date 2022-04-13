#!/bin/sh

echo "check if ethernet adapter is present"
 if [[ ! -d /sys/class/net/eth* ]]; then
        echo "usb ethernet not present"
	if [[ ! -d /sys/class/net/usb0* ]]; then
        	echo "usb host not present"
	else
        ifconfig usb0 down                            
        ifconfig wlan0 down                              
	/media/mmc/busybox ip link set wlan0 address 02:01:02:03:04:08                                                         
        /media/mmc/busybox ip link set wlan0 name wlanold
        /media/mmc/busybox ip link set usb0 name wlan0
                                                        
        ifconfig wlan0 up                               
        udhcpc -i wlan0                          
        /media/mmc/dropbearmulti dropbear -R -m &       
        sleep 5                                         
        mount -o bind /media/mmc/wpa_cli.sh /bin/wpa_cli	
	fi
    else
        ifconfig eth0 down
        ifconfig wlan0 down

        /media/mmc/busybox ip link set wlan0 name wlanold 
        /media/mmc/busybox ip link set eth0 name wlan0

        ifconfig wlan0 up
        udhcpc -i wlan0
        /media/mmc/dropbearmulti dropbear -R -m &
        sleep 5
        mount -o bind /media/mmc/wpa_cli.sh /bin/wpa_cli
    fi

echo set hostname
hostname WCV3_spare_test

echo Store dmesg logs
dmesg > /media/mmc/wz_mini/logs/dmesg.log

echo Run dropbear ssh server
/media/mmc/wz_mini/bin/dropbearmulti dropbear -R -m

#echo Disable remote firmware upgrade, uncomment lines below to enable
#mkdir /tmp/Upgrade
#mount -t tmpfs -o size=1,nr_inodes=1 none /tmp/Upgrade
#echo -e 127.0.0.1 localhost n127.0.0.1 wyze-upgrade-service.wyzecam.com > /tmp/hosts_wz
#mount --bind /tmp/hosts_wz /etc/hosts

sleep 3

#Place commands here to run 30 seconds after boot
#such as mount nfs, ping, etc

#mount -t nfs -o nolock,rw,noatime,nodiratime 192.168.1.1:/volume1 /media/mmc/record
