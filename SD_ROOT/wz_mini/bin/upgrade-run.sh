#!/bin/sh

if [ -L /dev/fd ]; then
	echo "fd exists" > /dev/null
else
	echo "fd does not exist, link" > /dev/null
	ln -s /proc/self/fd /dev/fd
fi

LOG_FILE=/opt/upgrade_wz_mini.log
exec > >(busybox tee -a ${LOG_FILE}) 2>&1

BRANCH="master"

setup() {

echo "Create Upgrade staging directory"
mkdir /opt/.Upgrade

echo "Create backup files directory"
mkdir /opt/.Upgrade/preserve

echo "Download latest $BRANCH"
wget --no-check-certificate https://github.com/gtxaspec/wz_mini_hacks/archive/refs/heads/$BRANCH.tar.gz -O /opt/.Upgrade/wz_mini.tar.gz; sync

echo "Extract $BRANCH archive"
mkdir /opt/.Upgrade/wz_mini_hacks
tar -xvf /opt/.Upgrade/wz_mini.tar.gz -C /opt/.Upgrade/wz_mini_hacks --strip-components 1

echo "Verify extracted file integrity"
cd /opt/.Upgrade/wz_mini_hacks
md5sum -c file.chk

if [ $? -eq 0 ]; then
	echo "File verification successful!"
	echo "Move staging directory to perform upgrade"
	mv /opt/.Upgrade/ /opt/Upgrade/
	install_upgrade_script
else
	echo "Failure: Extracted files may be corrupt.  Aborting upgrade."
	echo "Delete failed upgrade staging directory"
	rm -rf /opt/.Upgrade
	exit 1
fi

}

install_upgrade_script() {
echo "Installing latest upgrade-run from repo"
cp /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/bin/upgrade-run.sh /opt/wz_mini/bin/upgrade-run.sh

sleep 5

echo "Launching latest upgrade-script"
/opt/wz_mini/bin/upgrade-run.sh backup_begin &

echo "Exit old script"
rm -f /dev/fd
exit 0
}

backup_begin() {
echo "Resume upgrade-run, latest version"

echo "check for old directory path"
if [ -d /opt/Upgrade/wz_mini_hacks-master ]; then
	echo "old path found, moving"
	mv /opt/Upgrade/wz_mini_hacks-master /opt/Upgrade/wz_mini_hacks
fi

echo "enable wifi drivers if disabled in config"
sed -i 's/ENABLE_RTL8189FS_DRIVER="false"/ENABLE_RTL8189FS_DRIVER="true"/g' /opt/wz_mini/wz_mini.conf
sed -i 's/ENABLE_ATBM603X_DRIVER="false"/ENABLE_ATBM603X_DRIVER="true"/g' /opt/wz_mini/wz_mini.conf

sleep 5

echo "Backup user config"
cp /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/configs /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/ssh /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/wireguard /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/rc.local.d /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/cron /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/resolv.dnsmasq /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/go2rtc.yml /opt/Upgrade/preserve/

sync

echo "Rebooting into UPGRADE MODE"
reboot
}


upgrade_mode_start() {

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

set -x

#Set the correct GPIO for the audio driver (T31 only)
if [ -f /opt/wz_mini/tmp/.HL_PAN2 ]; then
	GPIO=7
elif [ -f /opt/wz_mini/tmp/.WYZE_CAKP2JFUS ]; then
	GPIO=63
fi

if [ -f /opt/wz_mini/tmp/.T20 ]; then
        insmod /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/lib/modules/3.10.14/extra/audio.ko
        LD_LIBRARY_PATH='/opt/wz_mini/lib' /opt/wz_mini/bin/audioplay_t20 /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/usr/share/audio/upgrade_mode_v2.wav $AUDIO_PROMPT_VOLUME
	rmmod audio
else
	insmod /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
        /opt/wz_mini/bin/audioplay_t31 /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/usr/share/audio/upgrade_mode.wav $AUDIO_PROMPT_VOLUME
        rmmod audio
fi

echo "UPGRADE MODE"

echo "Verify extracted file integrity"
cd /opt/Upgrade/wz_mini_hacks
md5sum -c file.chk

if [ $? -eq 0 ]; then
        echo "File verification successful!"
else
        echo "Failure: Extracted files may be corrupt.  Aborting upgrade."
        echo "Delete failed upgrade directory"
        rm -rf /opt/Upgrade
        reboot &
	exit 1
fi

if [ -f /opt/wz_mini/tmp/.T20 ]; then
	echo "Upgrading kernel"
	flashcp -v /opt/Upgrade/wz_mini_hacks/v2_install/v2_kernel.bin /dev/mtd1
fi

umount -l /opt/wz_mini/tmp
ls -l /opt/wz_mini/
rm -rf /opt/wz_mini/*
sync
mv /opt/Upgrade/wz_mini_hacks/SD_ROOT/wz_mini/* /opt/wz_mini/
rm -f /opt/factory_t31_ZMC6tiIDQN
mv /opt/Upgrade/wz_mini_hacks/SD_ROOT/factory_t31_ZMC6tiIDQN /opt/factory_t31_ZMC6tiIDQN

diff /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/wz_mini.conf

if [ $(cat /opt/Upgrade/preserve/wz_mini.conf | wc -l) != $(cat /opt/wz_mini/wz_mini.conf | wc -l) ]; then
	echo "doesn't match, keep old config"
	mv /opt/wz_mini/wz_mini.conf /opt/wz_mini/wz_mini.conf.dist
	cp /opt/Upgrade/preserve/wz_mini.conf /opt/wz_mini/
else
	echo "configs match"
	cp /opt/Upgrade/preserve/wz_mini.conf /opt/wz_mini/
fi

cp /opt/Upgrade/preserve/ssh/*  /opt/wz_mini/etc/ssh/
cp /opt/Upgrade/preserve/configs/*  /opt/wz_mini/etc/configs
cp -r /opt/Upgrade/preserve/wireguard  /opt/wz_mini/etc/
cp -r /opt/Upgrade/preserve/rc.local.d  /opt/wz_mini/etc/
cp /opt/Upgrade/preserve/cron/* /opt/wz_mini/etc/cron/
cp /opt/Upgrade/preserve/resolv.dnsmasq /opt/wz_mini/etc/resolv.dnsmasq
cp /opt/Upgrade/preserve/go2rtc.yml /opt/wz_mini/etc/go2rtc.yml

rm -rf /opt/Upgrade
sync
reboot

}

if [[ "$1" == "unattended" ]]; then
	echo "Unattended upgrade!"
	rm -rf /opt/.Upgrade
	rm -rf /opt/Upgrade
	sync
	setup
else

	if [[ -e /tmp/dbgflag ]]; then
		upgrade_mode_start
	else

		if [ "$1" == "backup_begin" ]; then
			backup_begin
		else

		read -r -p "${1:-wz_mini, this will download the latest version from github and upgrade your system.  Are you sure? [y/N]} " response
			case "$response" in
			[yY][eE][sS]|[yY])
			if [[ -d /opt/.Upgrade ]]; then
				echo "WARNING: Old Upgrade directory exists"
				read -r -p "${1:-Unable to proceed, must DELETE old Upgrade directory, are you sure? [y/N]} " response
				case "$response" in
				[yY][eE][sS]|[yY])
				rm -rf /opt/.Upgrade
				rm -rf /opt/Upgrade
				sync
				setup
				;;
				*)
				echo "User denied directory removal, exit"
				;;
	       			esac
		        else
				setup
	        	fi
			;;
		        *)
			echo "User declined system update, exit"
	        	;;
		    esac
		fi
	fi
fi
