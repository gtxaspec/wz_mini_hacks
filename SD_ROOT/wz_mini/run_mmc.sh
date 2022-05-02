#!/bin/sh

set -x

HOSTNAME="WCV3"

#####NETWORKING#####
ENABLE_USB_ETH="false"

ENABLE_USB_DIRECT="false"
USB_DIRECT_MAC_ADDR="02:01:02:03:04:08"

ENABLE_USB_RNDIS="false"

ENABLE_IPV6="false"

ENABLE_WIREGUARD="false"

#####ACCESSORIES#####
REMOTE_SPOTLIGHT="false"
REMOTE_SPOTLIGHT_HOST="0.0.0.0"

#####VIDEO STREAM#####
RTSP_ENABLED="false"
RTSP_ENABLE_AUDIO="false"
RTSP_LOGIN="admin"
RTSP_PASSWORD=""
RTSP_PORT="8554"

#####GENERAL#####
ENABLE_USB_STORAGE="false"
ENABLE_EXT4="false"
ENABLE_CIFS="false"
DISABLE_FW_UPGRADE="false"

#####DEBUG#####
DEBUG_ENABLED="false"
#drops you to a shell via serial, doesn't load app_init.sh

#####################################
##########CONFIG END#################
#####################################

echo  "run_mmc.sh start" > /dev/kmsg

echo "store original mac"
cat /sys/class/net/wlan0/address | tr '[:lower:]' '[:upper:]' > /opt/wz_mini/tmp/wlan0_mac

swap_enable() {
        if [[ -e /media/mmc/wz_mini/swap ]]; then
                echo "swap exists, enable"
                swapon /media/mmc/wz_mini/swap
        else
                echo "swap missing, system stability with usb potentially comprimised"
        fi
}

if [[ "$ENABLE_USB_RNDIS" == "true" ]]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/net/usb/usbnet.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/net/usb/cdc_ether.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/net/usb/rndis_host.ko

        swap_enable

        ifconfig usb0 down
        ifconfig wlan0 down

        /media/mmc/wz_mini/bin/busybox ip link set wlan0 name wlanold
        /media/mmc/wz_mini/bin/busybox ip addr flush dev wlanold
        /media/mmc/wz_mini/bin/busybox ip link set usb0 name wlan0

        ifconfig wlan0 up
        pkill udhcpc
        udhcpc -i wlan0 -x hostname:$HOSTNAME -p /var/run/udhcpc.pid -b
#        sleep 5
        mount -o bind /media/mmc/wz_mini/bin/wpa_cli.sh /bin/wpa_cli

else
	echo "rndis disabled"
fi

if [[ "$ENABLE_WIREGUARD" == "true" ]]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/tunnel4.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/ip_tunnel.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/wireguard/wireguard.ko
else
	echo "wireguard disabled"
fi

if [[ "$ENABLE_CIFS" == "true" ]]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/fs/cifs/cifs.ko
else
	echo "cifs disabled"
fi

if [[ "$ENABLE_USB_STORAGE" == "true" ]]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/scsi/scsi_mod.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/scsi/sd_mod.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/storage/usb-storage.ko
else
	echo "usb_storage disabled"
fi

if [[ "$ENABLE_EXT4" == "true" ]]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/fs/jbd2/jbd2.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/fs/mbcache.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/fs/ext4/ext4.ko
else
	echo "ext4 disabled"
fi

if [[ "$ENABLE_IPV6" == "true" ]]; then
echo "ipv6 enabled"
else
echo "ipv6 disabled"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
fi

if [[ "$ENABLE_USB_ETH" == "true" ]]; then

	swap_enable

	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/net/usb/usbnet.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/net/usb/asix.ko

        ifconfig eth0 down
        ifconfig wlan0 down

        /media/mmc/wz_mini/bin/busybox ip link set wlan0 name wlanold
        /media/mmc/wz_mini/bin/busybox ip addr flush dev wlanold
        /media/mmc/wz_mini/bin/busybox ip link set eth0 name wlan0

        ifconfig wlan0 up
	pkill udhcpc
        udhcpc -i wlan0 -x hostname:$HOSTNAME -p /var/run/udhcpc.pid -b
#        sleep 5
        mount -o bind /media/mmc/wz_mini/bin/wpa_cli.sh /bin/wpa_cli
	else
	        echo "usb ethernet disabled"
fi

if [[ "$ENABLE_USB_DIRECT" == "true" ]]; then

	#Set dwc2 ID_PIN driver memory
	devmem 0x13500000 32 0x001100cc
	devmem 0x10000040 32 0x0b000096
	#wipe the bits to set the ID_PIN
	devmem 0x10000040 32 0x0b000FFF

	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/libcomposite.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/u_ether.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/usb_f_ncm.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/g_ncm.ko iManufacturer=wz_mini_ncm

	sleep 1

        ifconfig usb0 down
        ifconfig wlan0 down
        /media/mmc/wz_mini/bin/busybox ip link set wlan0 name wlanold
        /media/mmc/wz_mini/bin/busybox ip addr flush dev wlanold
        /media/mmc/wz_mini/bin/busybox ip link set usb0 name wlan0
	/media/mmc/wz_mini/bin/busybox ip link set wlan0 address $USB_DIRECT_MAC_ADDR

        ifconfig wlan0 up
	pkill udhcpc
        udhcpc -i wlan0 -x hostname:$HOSTNAME -p /var/run/udhcpc.pid -b
        sleep 5
        mount -o bind /media/mmc/wz_mini/bin/wpa_cli.sh /bin/wpa_cli
	else
		echo "usb direct disabled"
fi

if [[ "$DISABLE_FW_UPGRADE" == "true" ]]; then
	mkdir /tmp/Upgrade
	mount -t tmpfs -o size=1,nr_inodes=1 none /tmp/Upgrade
	echo -e "127.0.0.1 localhost \n127.0.0.1 wyze-upgrade-service.wyzecam.com" > /opt/wz_mini/tmp/.storage/hosts
	mount --bind /opt/wz_mini/tmp/.storage/hosts /etc/hosts
else
        mkdir /tmp/Upgrade
        /opt/wz_mini/bin/busybox inotifyd /opt/wz_mini/usr/bin/watch_up.sh /tmp/Upgrade:n &
fi

if [[ "$REMOTE_SPOTLIGHT" == "true" ]]; then
	{ sleep 10; /media/mmc/wz_mini/bin/socat pty,link=/dev/ttyUSB0,raw tcp:$REMOTE_SPOTLIGHT_HOST:9000; } &

fi

if [[ "$RTSP_ENABLED" == "true" ]]; then
	swap_enable
        mkdir /tmp/alsa
        cp /media/mmc/wz_mini/etc/alsa.conf /tmp/alsa

	if [[ "$RTSP_PASSWORD" = "" ]]; then
	RTSP_PASSWORD=$(cat /opt/wz_mini/tmp/wlan0_mac)
	fi

        if [[ "$RTSP_ENABLE_AUDIO" == "true" ]]; then
                LD_LIBRARY_PATH=/media/mmc/wz_mini/lib /media/mmc/wz_mini/bin/v4l2rtspserver -C 1 -a S16_LE  /dev/video1,hw:Loopback,0 -U $RTSP_LOGIN:$RTSP_PASSWORD -P $RTSP_PORT &
        else
                echo "rtsp audio disabled"
                LD_LIBRARY_PATH=/media/mmc/wz_mini/lib /media/mmc/wz_mini/bin/v4l2rtspserver -s /dev/video1 -U $RTSP_LOGIN:$RTSP_PASSWORD -P $RTSP_PORT &
        fi
        else
        echo "rtsp disabled"
fi

echo "set hostname"
hostname $HOSTNAME

sleep 3

#################################################
##############CUSTOM BEGIN#######################
#################################################

#Place commands here to run 30 seconds after boot
#such as mount nfs, ping, etc

#mount -t nfs -o nolock,rw,noatime,nodiratime 192.168.1.1:/volume1 /media/mmc/record &
