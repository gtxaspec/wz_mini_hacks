# Entware Installation

## Prepare the SD card
You need to break your SD card into two partitions.  The first partition will be FAT32 for the wyze-mini-hacks and camera video.  The second partition will be EXT2 for entware.

There are multiple ways to do this.  Below is the process I followed to partition a 32GB micro-SD card into 24GB of FAT32 and 8GB of EXT2 using WSL2.

Create sparse a 32GB image file:
```shell
truncate -s 31242240k wyze.img
```
Create loopback device:
```shell
sudo losetup -fP wyze.img
```

Partition the loopback image:
```shell
sudo fdisk /dev/loop0
n
p
1
<cr>
+24G
n
p
2
<cr>
<cr>
w
```

Create the filesystems:
```shell
sudo mkfs.vfat /dev/loop0p1
sudo mkfs.ext2 /dev/loop0p2
```

Mount the FAT32 partition and follow the standard install instructions:
```shell
mkdir ./mnt/loop0p1 -p
sudo mount -t vfat /dev/loop0p1 ./mnt/loop0p1 -o umask=000
```

Create startup script:
```shell
cat - > mnt/loop0p1/mount_entware.sh <<EOT
#!/bin/sh

mkdir /media/boot
mount --move /opt /media/boot
mount -t ext2 /dev/mmcblk0p2 /opt
if [! -f /opt/wz_mini ]
then
    ln -s /media/boot/wz_mini /opt/wz_mini
fi

if [-f opt/etc/init.d/rc.unslung ]
then
    /opt/etc/init.d/rc.unslung start
fi
EOT
```

Edit mnt/loop0p1/wz_mini/wz_mini.conf and set CUSTOM_SCRIPT_PATH="/media/mmc/mount_entware.sh"

Unmount the image:
```shell
sudo umount mnt/loop0p1
```

I write the image to the SD card using https://www.balena.io/etcher/

## Boot the SD-CARD and verify EXT2 mounted
Assuming wz-mini-hacks is setup correct, you should be able to boot and ssh into the camera after a minute or two.  Verify ext2 is mounted in /opt:
```shell
mount | grep ext2
/dev/mmcblk0p2 on /opt type ext2 (rw,relatime)
```

## Install entware:
Run this commmand:
```shell
wget -O - http://bin.entware.net/mipselsf-k3.4/installer/generic.sh | sh
```
Assuming it works, it will do a bunch of downloads, and then end with a message like:
```shell
Info: Add /opt/bin & /opt/sbin to $PATH variable
```

You can follow this advice and update the file /etc/profile as desired.

## Use entware
You should now be able to ssh into the camera and use opkg to install entware packages.
