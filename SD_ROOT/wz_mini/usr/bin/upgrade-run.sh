#!/bin/sh

if [ -L /dev/fd ]; then
echo fd exists
else
echo fd does not exist, link
ln -s /proc/self/fd /dev/fd
fi

LOG_FILE=/opt/wz_upgrade.log
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

cp /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/ssh /opt/Upgrade/preserve/
cp -r /opt/wz_mini/etc/wireguard /opt/Upgrade/preserve/
sync
reboot
}


upgrade_mode_start() {

set -x

echo UPGRADE MODE

umount /opt/wz_mini/tmp
rm -rf /opt/wz_mini/*
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/wz_mini/* /opt/wz_mini/
rm -f /opt/factory_t31_ZMC6tiIDQN
mv /opt/Upgrade/wz_mini_hacks-master/SD_ROOT/factory_t31_ZMC6tiIDQN /opt/factory_t31_ZMC6tiIDQN

diff /opt/wz_mini/wz_mini.conf /opt/Upgrade/preserve/wz_mini.conf
cp /opt/Upgrade/preserve/wz_mini.conf /opt/wz_mini/
cp /opt/Upgrade/preserve/ssh/*  /opt/wz_mini/etc/ssh/
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
