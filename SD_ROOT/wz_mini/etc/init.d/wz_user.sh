#!/bin/sh

LOG_NAME=/opt/wz_mini/log/wz_user
if [[ -e $LOG_NAME.log || -L $LOG_NAME.log ]] ; then
    i=0
    while [[ -e $LOG_NAME.log.$i || -L $LOG_NAME.log.$i ]] ; do
        let i++
    done
        mv $LOG_NAME.log $LOG_NAME.log.$i
    LOG_NAME=$LOG_NAME
fi
touch -- "$LOG_NAME".log
exec 1> $LOG_NAME.log 2>&1

set -x

echo "welcome to wz_user.sh"
echo "PID $$"


if [[ -e /tmp/dbgflag ]];then
        echo "debug mode, disabled"
        exit 0
fi

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

hostname_set() {
	echo "set hostname"
	hostname $CUSTOM_HOSTNAME
}

first_run_check() {
	if [ -e /opt/wz_mini/tmp/.wz_user_firstrun ]; then
	echo "wz_user.sh already run once, exit."
	exit 0
	fi
}

store_mac() {
	echo "store original mac"
	cat /sys/class/net/wlan0/address | tr '[:lower:]' '[:upper:]' > /opt/wz_mini/tmp/wlan0_mac
}

wait_wlan() {
##Check if the driver has been loaded for the onboard wlan0, store the MAC.
    while true
    do
        if ifconfig wlan0 | grep "inet addr"; then
	        store_mac
		break
        elif ifconfig wlan0 | grep "inet addr" && [[ "$ENABLE_USB_ETH" == "true" || "$ENABLE_USB_DIRECT" == "true" ]]; then
	        store_mac
        	break
        fi
	        echo " wlan0 not ready yet..."
        	sleep 5
    done
}

rename_interface() {
##Fool iCamera by renaming the hardline interface to wlan0
	echo "renaming interfaces"
	ifconfig $1 down
	ifconfig wlan0 down
        /opt/wz_mini/bin/busybox ip link set wlan0 name wlanold
        /opt/wz_mini/bin/busybox ip addr flush dev wlanold
        /opt/wz_mini/bin/busybox ip link set $1 name wlan0
	eth_wlan_up
}

eth_wlan_up() {
##Run DHCP client, and bind mount our fake wpa_cli.sh to fool iCamera
        ifconfig wlan0 up
	pkill udhcpc
        udhcpc -i wlan0 -x hostname:$CUSTOM_HOSTNAME -p /var/run/udhcpc.pid -b
	if [ -f /opt/wz_mini/tmp/.T20 ]; then
        mount -o bind /opt/wz_mini/bin/wpa_cli.sh /system/bin/wpa_cli
	else
        mount -o bind /opt/wz_mini/bin/wpa_cli.sh /bin/wpa_cli
	fi
	break
}

wpa_check() {
#Check if wpa_supplicant has been created by iCamera
	if [ -e /tmp/wpa_supplicant.conf ]; then
		echo "wpa_supplicant.conf ready"
		wlanold_check $1
	else
		echo "wpa_supplicant.conf not ready, wait some time for creation."
		COUNT=0
		ATTEMPTS=15
		until [[ -e /tmp/wpa_supplicant.conf ]] || [[ $COUNT -eq $ATTEMPTS ]]; do
		echo -e "$(( COUNT++ ))... \c"
		sleep 5
		done
		[[ $COUNT -eq $ATTEMPTS ]] && echo "time exceeded waiting for iCamera, continue potentially broken condition without network." && wlanold_check $1
	fi
}

wlanold_check() {
#Have we renamed interfaces yet?
	if [ -d /sys/class/net/wlanold ]; then
		echo "wlanold exist"
		eth_wlan_up
	else
		echo "wlanold doesn't exist"
		rename_interface $1
	fi
}

netloop() {
##While loop for check
        while true
        do
        wpa_check $1
        echo "wlan0 not ready yet..."
        sleep 5
        done
}

swap_enable() {
        if [ -e /opt/wz_mini/swap ]; then
                echo "Swap file exists"
                if cat /proc/swaps | grep "mini" ; then
                        echo "Swap is already enabled"
                else
                        echo "Enable swap"
                        swapon /opt/wz_mini/swap
                fi
        else
                echo "Swap file missing!"
        fi
}

dmesg_log() {

DMESG_LOG=/opt/wz_mini/log/dmesg
if [[ -e $DMESG_LOG.log || -L $DMESG_LOG.log ]] ; then
    i=0
    while [[ -e $DMESG_LOG.log.$i || -L $DMESG_LOG.log.$i ]] ; do
        let i++
    done
        mv $DMESG_LOG.log $DMESG_LOG.log.$i
    DMESG_LOG=$DMESG_LOG
fi
touch -- "$DMESG_LOG".log
dmesg > $DMESG_LOG.log 2>&1

}

trim_logs() {

echo "Deleting logs older than 5 boots..."

find /opt/wz_mini/log -name '*log*' | while read file; do
  [ "${file#/opt/wz_mini/log/*log.}" -gt 5 ] && rm -v "$file"
done

}

first_run_check
wait_wlan

#Set module dir depending on platform
if [ -f /opt/wz_mini/tmp/.T20 ]; then
	KMOD_PATH="/opt/wz_mini/lib/modules/3.10.14"
else
	KMOD_PATH="/opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__"
fi

swap_enable

if [[ "$ENABLE_IPV6" == "true" ]]; then
	echo "ipv6 enabled"
else
	echo "ipv6 disabled"
	sysctl -w net.ipv6.conf.all.disable_ipv6=1
fi

if [[ "$ENABLE_NFSv4" == "true" ]]; then
        insmod $KMOD_PATH/kernel/lib/oid_registry.ko
        insmod $KMOD_PATH/kernel/net/dns_resolver/dns_resolver.ko
        insmod $KMOD_PATH/kernel/fs/nfs/nfsv4.ko
        insmod $KMOD_PATH/kernel/net/sunrpc/auth_gss/auth_rpcgss.ko
        echo nfsv4 enabled
else
        echo nfsv4 disabled
fi

if [[ "$ENABLE_IPTABLES" == "true"  ]]; then
        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		echo "T20 has iptables built in"
	else
		insmod /lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/netfilter/x_tables.ko
		insmod /lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/netfilter/ip_tables.ko
		insmod /lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/netfilter/ipt_REJECT.ko
		insmod /lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/netfilter/iptable_filter.ko
		insmod /lib/modules/3.10.14__isvp_swan_1.0__/kernel/net/ipv4/netfilter/iptable_mangle.ko
		echo "iptables ipv4 enabled"
	fi

	if [[ "$ENABLE_IPV6" == "true" ]]; then
		insmod $KMOD_PATH/kernel/net/ipv6/netfilter/ip6_tables.ko
		insmod $KMOD_PATH/kernel/net/ipv6/netfilter/ip6t_REJECT.ko
		insmod $KMOD_PATH/kernel/net/ipv6/netfilter/ip6table_filter.ko
		insmod $KMOD_PATH/kernel/net/ipv6/netfilter/ip6table_mangle.ko
		echo "iptables ipv6 enabled"
	fi
else
	echo "iptables disabled"
fi

if [[ "$ENABLE_USB_ETH" == "true" ]]; then

	insmod $KMOD_PATH/kernel/drivers/net/usb/usbnet.ko

	for DEVICE in `lsusb | awk '{print $6}'| tr '[:lower:]' '[:upper:]'`; do
		case $DEVICE in
		'0B95:1780' | '0B95:7720' | '0B95:772B')
			echo "Loading ASIX Ethernet driver..."
			modprobe asix
		;;
		'0B95:1790')
			echo "Loading AX88179 Gigabit Ethernet driver..."
			modprobe ax88179_178a
		esac
	done

	swap_enable

	netloop eth0

	else
	echo "usb ethernet disabled"
fi

if [[ "$ENABLE_USB_DIRECT" == "true" ]]; then

        HOST_MACADDR=$(echo "$CUSTOM_HOSTNAME"|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')

        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		echo connect > /sys/devices/platform/jz-dwc2/dwc2/udc/dwc2/soft_connect
		sleep 1
		devmem 0x10000040 32 0x0b800096
		sleep 1
		devmem 0x13500000 32 0x001100cc
	else
		#Set dwc2 ID_PIN driver memory
		devmem 0x13500000 32 0x001100cc
		devmem 0x10000040 32 0x0b000096
		#wipe the bits to set the ID_PIN, only for the V3.
		devmem 0x10000040 32 0x0b000FFF
	fi

	insmod $KMOD_PATH/kernel/drivers/usb/gadget/libcomposite.ko

        if [ -f /opt/wz_mini/tmp/.T31 ]; then
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/u_ether.ko
	insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/drivers/usb/gadget/usb_f_ncm.ko
	fi

	insmod $KMOD_PATH/kernel/drivers/usb/gadget/g_ncm.ko iManufacturer=wz_mini_ncm host_addr="$HOST_MACADDR" dev_addr="$USB_DIRECT_MAC_ADDR"

	sleep 1

	swap_enable

	#loop begin
	while true
	do
	wpa_check usb0
	echo "wlan0 not ready yet..."
        sleep 1
	done
	else
	echo "usb direct disabled"
fi

if [[ "$ENABLE_USB_RNDIS" == "true" ]]; then

	insmod $KMOD_PATH/kernel/drivers/net/usb/usbnet.ko
	insmod $KMOD_PATH/kernel/drivers/net/usb/cdc_ether.ko
	insmod $KMOD_PATH/kernel/drivers/net/usb/rndis_host.ko

	sleep 1

	swap_enable

	#loop begin
	while true
	do
	wpa_check usb0
	echo "wlan0 not ready yet..."
        sleep 1
	done
	else
	echo "usb direct disabled"
fi

if [[ "$ENABLE_WIREGUARD" == "true" ]]; then
	insmod $KMOD_PATH/kernel/net/ipv4/tunnel4.ko
	insmod $KMOD_PATH/kernel/net/ipv4/ip_tunnel.ko
	insmod $KMOD_PATH/kernel/net/wireguard/wireguard.ko

	if [[ "$WIREGUARD_IPV4" != "" ]]; then

		if [ -d /opt/wz_mini/etc/wireguard ]; then
			echo "wireguard dir exists"
		else
			mkdir -p /opt/wz_mini/etc/wireguard
		fi

	if [ ! -f /opt/wz_mini/etc/wireguard/privatekey ]; then
		(umask 277 && /opt/wz_mini/bin/wg  genkey | /opt/wz_mini/bin/busybox tee /opt/wz_mini/etc/wireguard/privatekey | /opt/wz_mini/bin/wg  pubkey > /opt/wz_mini/etc/wireguard/publickey)
	fi

	/opt/wz_mini/bin/busybox ip link add dev wg0 type wireguard
	/opt/wz_mini/bin/busybox ip address add dev wg0 "$WIREGUARD_IPV4"
	/opt/wz_mini/bin/wg set wg0 private-key /opt/wz_mini/etc/wireguard/privatekey
	/opt/wz_mini/bin/busybox ip link set wg0 up
	fi

	if [[ "$WIREGUARD_PEER_PUBLIC_KEY" != "" ]] && [[ "$WIREGUARD_PEER_ALLOWED_IPS" != "" ]] && [[ "$WIREGUARD_PEER_ENDPOINT" != "" ]] && [[ "$WIREGUARD_PEER_KEEP_ALIVE" != "" ]]; then
		/opt/wz_mini/bin/wg set wg0 peer "$WIREGUARD_PEER_PUBLIC_KEY" allowed-ips "$WIREGUARD_PEER_ALLOWED_IPS" endpoint "$WIREGUARD_PEER_ENDPOINT" persistent-keepalive "$WIREGUARD_PEER_KEEP_ALIVE"
		/opt/wz_mini/bin/busybox ip route add "$WIREGUARD_PEER_ALLOWED_IPS" dev wg0
	fi
else
	echo "wireguard disabled"
fi

if [[ "$ENABLE_CIFS" == "true" ]]; then
	insmod $KMOD_PATH/kernel/fs/cifs/cifs.ko
else
	echo "cifs disabled"
fi

if [[ "$ENABLE_USB_STORAGE" == "true" ]]; then
	insmod $KMOD_PATH/kernel/drivers/scsi/scsi_mod.ko
	insmod $KMOD_PATH/kernel/drivers/scsi/sd_mod.ko
	insmod $KMOD_PATH/kernel/drivers/usb/storage/usb-storage.ko
else
	echo "usb_storage disabled"
fi

if [[ "$ENABLE_EXT4" == "true" ]]; then
        if [ -f /opt/wz_mini/tmp/.T20 ]; then
	insmod $KMOD_PATH/kernel/lib/crc16.ko
	fi

	insmod $KMOD_PATH/kernel/fs/jbd2/jbd2.ko
	insmod $KMOD_PATH/kernel/fs/mbcache.ko
	insmod $KMOD_PATH/kernel/fs/ext4/ext4.ko
else
	echo "ext4 disabled"
fi

if [[ "$DISABLE_FW_UPGRADE" == "true" ]]; then
	mkdir /tmp/Upgrade
	mount -t tmpfs -o size=1,nr_inodes=1 none /tmp/Upgrade
	echo -e "127.0.0.1 localhost \n127.0.0.1 wyze-upgrade-service.wyzecam.com" > /opt/wz_mini/tmp/.storage/hosts
	mount --bind /opt/wz_mini/tmp/.storage/hosts /etc/hosts
else
        mkdir /tmp/Upgrade
        /opt/wz_mini/bin/busybox inotifyd /opt/wz_mini/usr/bin/watch_up.sh /tmp:n &
fi

if [[ "$REMOTE_SPOTLIGHT" == "true" ]]; then
	/opt/wz_mini/bin/socat pty,link=/dev/ttyUSB0,raw tcp:"$REMOTE_SPOTLIGHT_HOST":9000 &
	echo "remote accessory enabled"
else
	echo "remote accessory disabled"
fi

if [[ "$ENABLE_MP4_WRITE" == "true" ]]; then
        if [ -f /opt/wz_mini/tmp/.T20 ]; then
		echo "mp4_write is not supported on T20"
	else
		/opt/wz_mini/bin/cmd mp4write on
		echo "mp4_write enabled"
	fi
else
	echo "mp4 write disabled"
fi

if [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then

        if [ -f /opt/wz_mini/tmp/.T20 ]; then
	HI_VIDEO_DEV="/dev/video6"
	else
	HI_VIDEO_DEV="/dev/video1"
	fi

	swap_enable

	if [[ "$RTSP_PASSWORD" = "" ]]; then
	RTSP_PASSWORD=$(cat /opt/wz_mini/tmp/wlan0_mac)
	fi

	/opt/wz_mini/bin/cmd video on

        if [[ "$RTSP_HI_RES_ENABLE_AUDIO" == "true" ]]; then
		/opt/wz_mini/bin/cmd audio on
		AUDIO_CH="-C 1"
		AUDIO_FMT="-a S16_LE"
		DEVICE1="$HI_VIDEO_DEV,hw:Loopback,0"
        else
                DEVICE1="$HI_VIDEO_DEV"
		echo "rtsp audio disabled"
        fi

        if [[ "$RTSP_HI_RES_ENC_PARAMETER" != "" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:0:4:$RTSP_HI_RES_ENC_PARAMETER" > /dev/null 2>&1 &
				sleep 5
                        else
                                echo "Invalid encoder value"
                        fi
                else
                        if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:44:4:$RTSP_HI_RES_ENC_PARAMETER" > /dev/null 2>&1 &
				sleep 5
                        else
                                echo "Invalid encoder value"
                        fi
                fi
        fi

	if [[ "$RTSP_HI_RES_MAX_BITRATE" != "" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:28:4:$RTSP_HI_RES_MAX_BITRATE" > /dev/null 2>&1 &
			sleep 5
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:52:4:$RTSP_HI_RES_MAX_BITRATE" > /dev/null 2>&1 &
			sleep 5
		fi
	fi

	if [[ "$RTSP_HI_RES_TARGET_BITRATE" != "" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
			echo "not supported on T20"
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:48:4:$RTSP_HI_RES_TARGET_BITRATE" > /dev/null 2>&1 &
			sleep 5
		fi
	fi

	if [[ "$RTSP_HI_RES_FPS" != "" ]]; then
	        if [ -f /opt/wz_mini/tmp/.T20 ]; then
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:8:4:$RTSP_HI_RES_FPS" > /dev/null 2>&1 &
			sleep 5
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 0:80:4:$RTSP_HI_RES_FPS" > /dev/null 2>&1 &
			sleep 5
		fi
	fi

        else
        echo "rtsp disabled"

fi


if [[ "$RTSP_LOW_RES_ENABLED" == "true" ]]; then

	if [ -f /opt/wz_mini/tmp/.T20 ]; then
	LOW_VIDEO_DEV="/dev/video7"
	else
	LOW_VIDEO_DEV="/dev/video2"
	fi

	swap_enable

	/opt/wz_mini/bin/cmd video on1

	if [[ "$RTSP_PASSWORD" = "" ]]; then
	RTSP_PASSWORD=$(cat /opt/wz_mini/tmp/wlan0_mac)
	fi

        if [[ "$RTSP_LOW_RES_ENABLE_AUDIO" == "true" ]]; then
		/opt/wz_mini/bin/cmd audio on1
		AUDIO_CH="-C 1"
		AUDIO_FMT="-a S16_LE"
		DEVICE2="$LOW_VIDEO_DEV,hw:Loopback,1"
        else
                DEVICE2="$LOW_VIDEO_DEV"
                echo "rtsp audio disabled"
        fi

        if [[ "$RTSP_LOW_RES_ENC_PARAMETER" != "" ]]; then
		if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:0:4:$RTSP_LOW_RES_ENC_PARAMETER" > /dev/null 2>&1 &
				sleep 5
                        else
                                echo "Invalid encoder value"
                        fi
                else
                        if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:44:4:$RTSP_LOW_RES_ENC_PARAMETER" > /dev/null 2>&1 &
                        else
                                echo "Invalid encoder value"
                        fi
                fi
        fi

	if [[ "$RTSP_LOW_RES_MAX_BITRATE" != "" ]]; then
		if [ -f /opt/wz_mini/tmp/.T20 ]; then
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:28:4:$RTSP_LOW_RES_MAX_BITRATE" > /dev/null 2>&1 &
			sleep 5
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:52:4:$RTSP_LOW_RES_MAX_BITRATE" > /dev/null 2>&1 &
		fi
	fi

	if [[ "$RTSP_LOW_RES_TARGET_BITRATE" != "" ]]; then
		if [ -f /opt/wz_mini/tmp/.T20 ]; then
			echo "not supported on T20"
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:48:4:$RTSP_LOW_RES_TARGET_BITRATE" > /dev/null 2>&1 &
		fi
	fi

	if [[ "$RTSP_LOW_RES_FPS" != "" ]]; then
		if [ -f /opt/wz_mini/tmp/.T20 ]; then
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:8:4:$RTSP_LOW_RES_FPS" > /dev/null 2>&1 &
			sleep 5
		else
			watch -n30 -t "/system/bin/impdbg --enc_rc_s 1:80:4:$RTSP_LOW_RES_FPS" > /dev/null 2>&1 &
		fi
	fi

        else
        echo "rtsp disabled"

fi

if [[ "$RTSP_LOW_RES_ENABLED" == "true" ]] || [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then
	echo "delay RTSP for iCamera"
	#This delay is required. Sometimes, if you start the rtsp server too soon, live view will break on the app.
	sleep 5
	LD_LIBRARY_PATH=/opt/wz_mini/lib /opt/wz_mini/bin/v4l2rtspserver $AUDIO_CH $AUDIO_FMT -U "$RTSP_LOGIN":"$RTSP_PASSWORD" -P "$RTSP_PORT" $DEVICE1 $DEVICE2 &
fi

if ([[ "$RTSP_LOW_RES_ENABLED" == "true" ]] || [[ "$RTSP_HI_RES_ENABLED" == "true" ]]) && [[ "$RTMP_STREAM_ENABLED" == "true" ]] && ([[ "$RTSP_LOW_RES_ENABLE_AUDIO" == "true" ]] || [[ "$RTSP_HI_RES_ENABLE_AUDIO" == "true" ]]); then
	if [[ "$RTMP_STREAM_DISABLE_AUDIO" == "true" ]]; then
		RMTP_AUDIO="no_audio"
	fi
	echo "delay RTMP server"
	#Follow the delay from the RTSP server
	sleep 5
	/opt/wz_mini/bin/rtmp-stream.sh "$RMTP_STREAM_SERVICE" "$RTMP_AUDIO"
fi

hostname_set
touch /opt/wz_mini/tmp/.wz_user_firstrun
pkill -f dumpload #Kill dumpload so it won't waste cpu or ram gathering cores and uploading them when something crashes
sysctl -w kernel.core_pattern='|/bin/false'
dmesg_log
trim_logs
sync;echo 3 > /proc/sys/vm/drop_caches


if [ -f "$CUSTOM_SCRIPT_PATH" ]; then
	echo "starting custom script"
	$CUSTOM_SCRIPT_PATH &
else
	echo "custom script not found"
fi

echo "wz_user.sh done" > /dev/kmsg
