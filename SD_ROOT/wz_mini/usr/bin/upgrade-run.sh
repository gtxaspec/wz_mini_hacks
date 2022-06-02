#!/bin/sh

if [ -L /dev/fd ]; then
echo fd exists
else
echo fd does not exist, link
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

if [ $? -eq 0 ]
then
  echo "files OK"
  #exit 0
else
  echo "Failure: archive has corrupted files"
  exit 1
fi

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

set -x

#WCV3 AUDIO GPIO
GPIO=63

#Check model, change GPIO is HL_PAN2
if [[ "$V2" == "false" ]]; then
        mount -t jffs2 /dev/mtdblock6 /configs
        if [[ $(cat /configs/.product_config  | grep PRODUCT_MODEL) == "PRODUCT_MODEL=HL_PAN2" ]]; then
        umount /configs
        GPIO=7
        fi
else
        echo "not HL_PAN2"
fi


#test for v2
if [ -b /dev/mtdblock9 ]; then
        mount -t jffs2 /dev/mtdblock9 /params
        if cat /params/config/.product_config | grep WYZEC1-JZ; then
                V2="true"
        fi
fi


if [[ "$V2" == "true" ]]; then
              insmod /opt/wz_mini/lib/modules/3.10.14_v2/kernel/audio.ko
              LD_LIBRARY_PATH='/opt/wz_mini/lib' /opt/wz_mini/bin/audioplay_t20 /opt/wz_mini/usr/share/audio/upgrade_mode_v2.wav 70
              rmmod audio
      else
              insmod /opt/wz_mini/lib/modules/3.10.14__isvp_swan_1.0__/kernel/audio.ko spk_gpio=$GPIO alc_mode=0 mic_gain=0
              /opt/wz_mini/bin/audioplay_t31 /opt/wz_mini/usr/share/audio/upgrade_mode.wav 50
              rmmod audio
      fi

echo UPGRADE MODE

umount -l /opt/wz_mini/tmp
ls -l /opt/wz_mini/
rm -rf /opt/wz_mini/*
sync
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/* /opt/wz_mini/
rm -f /opt/factory_t31_ZMC6tiIDQN
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/factory_t31_ZMC6tiIDQN /opt/factory_t31_ZMC6tiIDQN

diff /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/wz_mini.conf
cp /opt/Upgrade/preserve/wz_mini.conf /opt/wz_mini/
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
