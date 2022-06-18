#!/bin/sh

if [ -L /dev/fd ]; then
	echo "fd exists" > /dev/null
else
	echo "fd does not exist, link" > /dev/null
	ln -s /proc/self/fd /dev/fd
fi

LOG_FILE=/opt/upgrade_wz_mini.log
exec > >(busybox tee -a ${LOG_FILE}) 2>&1

setup() {

echo "Create Upgrade directory"
mkdir /opt/Upgrade

echo "Create backup files directory"
mkdir /opt/Upgrade/preserve

echo "Download latest master"
wget --no-check-certificate https://github.com/gtxaspec/wz_mini_hacks/archive/refs/heads/master.zip -O /opt/Upgrade/wz_mini.zip; sync

echo "Extract archive"
unzip /opt/Upgrade/wz_mini.zip -d /opt/Upgrade/

echo "Verify file integrity"
cd /opt/Upgrade/wz_mini_hacks-master
md5sum -c file.chk

if [ $? -eq 0 ]; then
	echo "files OK"
	install_upgrade_script
else
	echo "Failure: archive has corrupted files"
	echo "Delete failed upgrade dir"
	rm -rf /opt/Upgrade
	exit 1
fi

}

install_upgrade_script() {
echo "Installing latest upgrade-run from repo"
cp /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/bin/upgrade-run.sh /opt/wz_mini/bin/upgrade-run.sh

sleep 5

echo "Launching latest upgrade-script"
/opt/wz_mini/bin/upgrade-run.sh backup_begin &

echo "Exit old script"
rm -f /dev/fd
exit 0
}

backup_begin() {
echo "Resume upgrade-run, latest version"

sleep 5

echo "Backup user config"
cp /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/configs /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/ssh /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/wireguard /opt/Upgrade/preserve/
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
        insmod /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/lib/modules/3.10.14/extra/audio.ko
        LD_LIBRARY_PATH='/opt/wz_mini/lib' /opt/wz_mini/bin/audioplay_t20 /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/usr/share/audio/upgrade_mode_v2.wav $AUDIO_PROMPT_VOLUME
	rmmod audio
else
	insmod /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/extra/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
        /opt/wz_mini/bin/audioplay_t31 /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/usr/share/audio/upgrade_mode.wav $AUDIO_PROMPT_VOLUME
        rmmod audio
fi

echo "UPGRADE MODE"

if [ -f /opt/wz_mini/tmp/.T20 ]; then
	echo "Upgrading kernel"
	flashcp -v /opt/Upgrade/wz_mini_hacks-master/v2_install/v2_kernel.bin /dev/mtd1
fi

umount -l /opt/wz_mini/tmp
ls -l /opt/wz_mini/
rm -rf /opt/wz_mini/*
sync
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/* /opt/wz_mini/
rm -f /opt/factory_t31_ZMC6tiIDQN
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/factory_t31_ZMC6tiIDQN /opt/factory_t31_ZMC6tiIDQN

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
rm -rf /opt/Upgrade
sync
reboot

}

if [[ -e /tmp/dbgflag ]]; then
	upgrade_mode_start
else

if [ "$1" == "backup_begin" ]; then
	backup_begin
else

read -r -p "${1:-wz_mini, this will download the latest version from github and upgrade your system.  Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
        if [[ -d /opt/Upgrade ]]; then
                echo "WARNING: Old Upgrade directory exists"
                read -r -p "${1:-Unable to proceed, must DELETE old Upgrade directory, are you sure? [y/N]} " response
                case "$response" in
                [yY][eE][sS]|[yY])
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
