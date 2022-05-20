# process


build kernel with initramfs

initramfs ```/etc/init``` runs ```exec busybox switch_root /v3 /opt/wz_mini/etc/init.d/v3_init.sh```

within ```/opt/wz_mini/etc/init.d/v3_init.sh```:

bind replace ```/etc/init.d/inittab``` with our own version that has rcS located at ```/opt/wz_mini/tmp/.storage/rcS```

bind replace ```/etc/profile``` with out own version with added PATH variables for the shell

mount ```/tmp``` and ```/run```

mount ```/system```

bind replace ```/system/bin/factorycheck```, this stock firmware program unmounts the binds that we do later in the file, its a debug program.  We don't need it.

bind replace ```/etc/fstab``` with our own version which includes ```/opt/wz_mini/tmp``` as a tmpfs path

create wz_mini's workplace directory at ```/opt/wz_mini/tmp```

copy the stock ```/etc/init.d/rcS``` to the workplace directory

modify the stock rcS, add ```set -x``` debug mode, inject the following script ```/opt/wz_mini/etc/init.d/v3_post.sh``` to run, and add a section to change PATH and LD_LIBRARY if desired

bind replace ```/etc/shadow``` to change the stock password

check to see if the swap archive is present at ```/opt/wz_mini/swap.gz```, if it is, extract it, then mkswap it, and drop the vm cache.

check to see if the ```/opt/wz_mini/usr/share/terminfo``` directory is present, if not, extract the terminfo files for console programs

mount ```/configs``` to check if the ```.ssh``` dir is present, a requirement for the dropbear ssh server

check to see if ```/opt/wz_mini/run_mmc.sh``` has debug mode enabled, if it does, skip loading ```/system/bin/app_init.sh``` and ```/media/mmc/wz_mini/run_mmc.sh```

run ```/media/mmc/wz_mini/run_mmc.sh```, but delay execution for 30 seconds, enough time for WiFi or wired ethernet/usb to load and connect successfully to the internet

run ```/linuxrc``` to kick off the stock boot process

our modified inittab runs from ```/opt/wz_mini/tmp/.storage/rcS```, we have enabled set -x debug info, added ```/opt/wz_mini/bin``` and ```/opt/wz_mini/lib``` to the system PATH's, and added ```/opt/wz_mini/etc/init.d/v3_post.sh``` to run before ```/system/init/app_init.sh``` runs.

```/opt/wz_mini/etc/init.d/v3_post.sh``` checks if ```run_mmc.sh``` has the RTSP server enabled, and if it does, we copy ```/system/bin/iCamera``` to our workplace directory at ```/opt/wz_mini/tmp/.storage/```

bind replace ```/system/bin/iCamera```

our version of iCamera is a script which injects the libcallback.so library as LD_PRELOAD to hook the Audio and Video to the RTSP Server, calling iCamera from it's new home at ```/opt/wz_mini/tmp/.storage/```

we then load the video loopback driver from ```/opt/wz_mini/lib/modules/v4l2loopback.ko```

```/system/bin/app_init.sh``` loads the stock system software

During execution of ```run_mmc.sh```, if ```DISABLE_FW_UPGRADE``` is set to ```false``` we intercept the stock firmware upgrade process.  We run ```inotifyd``` at startup, to observe the /tmp/Upgrade directory.

Normally, ```iCamera``` downloads the firmware upgrade tar to ```/tmp/img```, renames it to ```/tmp/Upgrade.tar```, then extracts it to ```/tmp/Upgrade```

```inotifyd``` monitors ```/tmp/Upgrade``` for the file ```upgraderun.sh```, this is the script responsible for flashing the firmware files to their respective partitions.  Once the file appears, ```inotifyd``` calls the script ```/opt/wz_mini/usr/bin/watch_up.sh``` which will rename the file to ```upgraderun.old``` and kill the script if ```iCamera``` was fast enough to launch it before we renamed it.  

```watch_up.sh``` will then proceed to flash the main partitions directly, instead of doing what the stock script does, which is to flash the images to backup partitions, and then let the bootloader flash the main partitions upon reboot, since this process is currently broken when using the loading the kernel from the micro sd card, which we do.


Once the partitions have been flashed, we reboot the camera, and the FW upgrade is complete.
