#!/bin/bash

LATEST_ROOTFS="4.36.3.19"
LATEST_FW="4.36.8.32"

clean() {
rm -f *.tar*
rm -rf ./*_ext
rm -rf SD_ROOT
}


setup() {
echo "Create SD Card root directory"
mkdir SD_ROOT

echo "Copy utils to SD_ROOT"
wget https://www.busybox.net/downloads/binaries/1.21.1/busybox-mipsel -O SD_ROOT/busybox
cp dropbearmulti SD_ROOT

echo "Download latest rootfs firmware $LATEST_ROOTFS"

wget https://s3-us-west-2.amazonaws.com/wuv2/upgrade/WYZE_CAKP2JFUS/firmware/$LATEST_ROOTFS.tar
mkdir "$LATEST_ROOTFS"_ext
tar -xf $LATEST_ROOTFS.tar -C ./"$LATEST_ROOTFS"_ext

echo "Download latest stable firmware $LATEST_FW"

mkdir "$LATEST_FW"_ext
wget https://s3-us-west-2.amazonaws.com/wuv2/upgrade/WYZE_CAKP2JFUS/firmware/$LATEST_FW.tar
tar -xf $LATEST_FW.tar -C ./"$LATEST_FW"_ext

echo "Extract rootfs, prepare for modification"
unsquashfs -d ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs

echo "Change unknown stock password to WYom2020 in /etc/shadow"
rm -rf ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow
echo "root:aVG8.5PMEOfnQ:0:0:99999:7:::" > ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow
chmod 400 ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/shadow

echo "Add run_mmc.sh to rootfs rcS init.d script"
sed -i '/\-f\ \/system\/init\/app_init.sh/a { sleep 30; /media/mmc/run_mmc.sh > /media/mmc/wz_mini_hacks.log; } &' ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir/etc/init.d/rcS

echo "repack rootfs for flashing"
mksquashfs ./"$LATEST_ROOTFS"_ext/Upgrade/rootfs_dir SD_ROOT/rootfs2.bin -noappend -all-root -comp xz

echo "copy latest appfs and kernel to SD_ROOT"
cp ./"$LATEST_FW"_ext/Upgrade/app SD_ROOT/appfs.bin
cp ./"$LATEST_FW"_ext/Upgrade/kernel SD_ROOT/kernel.bin

echo "extract run_mmc.sh script to SD_ROOT"

echo "#!/bin/sh

echo "Store dmesg logs"
dmesg > /media/mmc/dmesg.log

#echo "Run telnetd"
#/media/mmc/busybox telnetd &

echo "Run dropbear ssh server"
/media/mmc/dropbearmulti dropbear -R -m

sleep 3

#Place commands here to run 30 seconds after boot
#such as mount nfs, ping, etc

#mount -t nfs -o nolock,rw,noatime,nodiratime 192.168.1.1:/volume1 /media/mmc/record

" > SD_ROOT/run_mmc.sh
chmod 755 SD_ROOT/run_mmc.sh

echo "extract wz_mini_installer.sh to SD_ROOT"

echo "#!/bin/sh

echo this must be run ON the camera itself
#add check to make sure this is only run on camera, use appver file -z
#check that bin files exist first before flashing, and compare SHA512

echo "create /configs/.ssh dir for dropbear ssh server"
mkdir /configs/.ssh

echo flash kernel to mtd1
flashcp -v /media/mmc/kernel.bin /dev/mtd1

echo flash apps to mtd3
flashcp -v /media/mmc/appfs.bin /dev/mtd3

echo flash modified rootfs to mtd2
flashcp -v /media/mmc/rootfs2.bin /dev/mtd2

echo done, rebooting.
echo WARN: IF REBOOT FAILS, OR SEGMENTATION FAULT ERROR OCCURS, PLEASE POWER CYCLE THE wyze v3 CAMERA MANUALLY BY REOMVING THE POWER CORD.

sync
sync
reboot


" > SD_ROOT/wz_mini_installer.sh
chmod 755 SD_ROOT/wz_mini_installer.sh

#echo "Extract appfsfs"
#unsquashfs -d ./436832_ext/Upgrade/ rootfs

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
