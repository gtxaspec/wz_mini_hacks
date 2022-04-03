#!/bin/bash

LATEST_ROOTFS="4.36.3.19"
LATEST_FW="4.36.8.32"

clean() {
rm -rf tmp_root
rm -rf SD_ROOT
}


setup() {
echo "Create SD Card root directory"
mkdir SD_ROOT

echo "Copy test to SD_ROOT"
cp Test.tar SD_ROOT

echo "Download utilities to SD_ROOT"
wget https://www.busybox.net/downloads/binaries/1.21.1/busybox-mipsel -O SD_ROOT/busybox

echo "Copy locla utilities to SD_ROOT"
cp dropbearmulti SD_ROOT

echo "Download latest rootfs firmware $LATEST_ROOTFS"

wget https://s3-us-west-2.amazonaws.com/wuv2/upgrade/WYZE_CAKP2JFUS/firmware/$LATEST_ROOTFS.tar --directory-prefix=./tmp_root/
mkdir ./tmp_root/"$LATEST_ROOTFS"_ext
tar -xf ./tmp_root/$LATEST_ROOTFS.tar -C ./tmp_root/"$LATEST_ROOTFS"_ext

echo "Download latest stable firmware $LATEST_FW"

mkdir ./tmp_root/"$LATEST_FW"_ext
wget https://s3-us-west-2.amazonaws.com/wuv2/upgrade/WYZE_CAKP2JFUS/firmware/$LATEST_FW.tar --directory-prefix=./tmp_root/
tar -xf ./tmp_root/$LATEST_FW.tar -C ./tmp_root/"$LATEST_FW"_ext

echo "Extract rootfs, prepare for modification"
unsquashfs -d ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs

##test

mkdir ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/.ssh

echo "Change unknown stock password to WYom2020 in /etc/shadow"
rm -rf ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow
echo "root:aVG8.5PMEOfnQ:0:0:99999:7:::" > ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow
chmod 400 ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow

echo "Add run_mmc.sh to rootfs rcS init.d script"
sed -i '/\-f\ \/system\/init\/app_init.sh/a { sleep 30; /media/mmc/run_mmc.sh > /media/mmc/wz_mini_hacks.log; } &' ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/init.d/rcS

echo "repack rootfs for flashing"
mksquashfs ./tmp_root/"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir SD_ROOT/rootfs2.bin -noappend -all-root -comp xz

echo "copy latest appfs and kernel to SD_ROOT"
cp ./tmp_root/"$LATEST_FW"_ext/Upgrade/app SD_ROOT/appfs.bin
cp ./tmp_root/"$LATEST_FW"_ext/Upgrade/kernel SD_ROOT/kernel.bin

echo "extract run_mmc.sh script to SD_ROOT"

echo "#!/bin/sh

echo "set hostname"
hostname WCV3

echo "Store dmesg logs"
dmesg > /media/mmc/dmesg.log

#echo "Run telnetd"
#/media/mmc/busybox telnetd &

echo "Run dropbear ssh server"
/media/mmc/dropbearmulti dropbear -R -m

#echo "Disable remote firmware upgrade, uncomment lines below to enable"
#mkdir /tmp/Upgrade
#mount -t tmpfs -o size=1,nr_inodes=1 none /tmp/Upgrade
#echo -e "127.0.0.1 localhost \n127.0.0.1 wyze-upgrade-service.wyzecam.com" > /tmp/hosts_wz
#mount --bind /tmp/hosts_wz /etc/hosts

sleep 3

#Place commands here to run 30 seconds after boot
#such as mount nfs, ping, etc

#mount -t nfs -o nolock,rw,noatime,nodiratime 192.168.1.1:/volume1 /media/mmc/record

" > SD_ROOT/run_mmc.sh
chmod 755 SD_ROOT/run_mmc.sh

}


if [ "$1" == "clean" ]; then
clean
elif [ "$1" == "compile" ]; then
setup
else
echo "wz_mini_hacks setup script"
echo "Usage:"
echo "./setup.sh compile to download and patch firmware"
echo "./setup.sh clean to delete all downloaded files and clean directory"
fi
