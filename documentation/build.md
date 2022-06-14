# wz_mini boot process


load kernel with initramfs built in

***initramfs***: ```/etc/init``` runs ```exec busybox switch_root /v3 /opt/wz_mini/etc/init.d/v3_init.sh```

***```/opt/wz_mini/etc/init.d/v3_init.sh```:***

bind replace the factory busybox, which is missing a bunch of utilities, with our own fully featured version

mount ```/configs``` to check if the model of the camera is HL_PAN2.  If it is, change some variables.

mount ```/params``` if it exists, to check if the model of the camera is V2.  If it is, change some variable

Check if `/opt/wz_mini/etc/.first_boot` exists, if it does, play some audio to notify the user that the first boot init is running.

bind replace ```/etc/init.d/inittab``` with our own version that has rcS located at ```/opt/wz_mini/tmp/.storage/rcS```

bind replace ```/etc/profile``` with out own version with added PATH variables for the shell

mount ```/tmp```

mount ```/system```

create the file `touch /tmp/usrflag` to make iCamera happy, normally created by `/system/bin/factorycheck`

bind replace ```/system/bin/factorycheck```, this factory included program unmounts the binds that we do later in the script, since its a debug program, we don't need it.  Replace it with a fake.

bind replace ```/etc/fstab``` with our own version which includes ```/opt/wz_mini/tmp``` as a tmpfs path

mount wz_mini's tmp directory at ```/opt/wz_mini/tmp```

install our `busybox`'s applets to `/opt/wz_mini/tmp/.bin`

create a workplace directory for wz_mini at `/opt/wz_mini/tmp/.storage`

copy the stock ```/etc/init.d/rcS``` to the workplace directory

modify the stock rcS, add ```set -x``` debug mode, inject the following script ```/opt/wz_mini/etc/init.d/wz_post.sh``` to run, and add a section to change PATH and LD_LIBRARY if desired

bind replace ```/etc/shadow``` to change the stock password

check to see if the swap archive is present at ```/opt/wz_mini/swap.gz```, if it is, extract it, then mkswap it, and drop the vm caches.

check to see if the ```/opt/wz_mini/usr/share/terminfo``` directory is present, if not, extract the terminfo files for console programs

run the `dropbear` ssh daemon


check to see if ```/opt/wz_mini/wz_user.sh``` has debug mode enabled, if it does, skip loading ```/system/bin/app_init.sh``` and ```/opt/wz_mini/etc/init.d/wz_user.sh```

check to see if ```/opt/wz_mini/wz_user.sh``` has webcam mode enabled, if it does, skip loading ```/system/bin/app_init.sh``` and instead load  ```/opt/wz_mini/etc/init.d/wz_cam.sh```

check to see if ```/opt/wz_mini/wz_user.sh``` has upgrade mode enabled, if it does, skip loading ```/system/bin/app_init.sh``` and instead load  ```/opt/wz_mini/usr/bin/upgrade-run.sh```

run ```/linuxrc``` to kick off the stock boot process

***inittab***:

our modified inittab runs from ```/opt/wz_mini/tmp/.storage/rcS```, we have enabled set -x debug info, added ```/opt/wz_mini/bin``` and ```/opt/wz_mini/lib``` to the system PATH's, and added ```/opt/wz_mini/etc/init.d/wz_post.sh``` to run before ```/system/init/app_init.sh``` runs.

```/opt/wz_mini/etc/init.d/wz_post.sh``` checks if ```wz_user.sh``` has the RTSP server enabled, and if it does, we copy ```/system/bin/iCamera``` to our workplace directory at ```/opt/wz_mini/tmp/.storage/```

bind replace ```/system/bin/iCamera```

our version of iCamera is a script which injects the libcallback.so library as LD_PRELOAD to hook the Audio and Video to the RTSP Server, calling iCamera from it's new home at ```/opt/wz_mini/tmp/.storage/```

we then load the video loopback driver from ```/opt/wz_mini/lib/modules/v4l2loopback.ko```

```/system/bin/app_init.sh``` loads the stock system software

During execution of ```wz_user.sh```, if ```DISABLE_FW_UPGRADE``` is set to ```false``` we intercept the stock firmware upgrade process.  We run ```inotifyd``` at startup, to observe the /tmp/Upgrade directory.

Normally, ```iCamera``` downloads the firmware upgrade tar to ```/tmp/img```, renames it to ```/tmp/Upgrade.tar```, then extracts it to ```/tmp/Upgrade```

```inotifyd``` monitors ```/tmp/Upgrade``` for the file ```upgraderun.sh```, this is the script responsible for flashing the firmware files to their respective partitions.  Once the file appears, ```inotifyd``` calls the script ```/opt/wz_mini/usr/bin/watch_up.sh``` which will rename the file to ```upgraderun.old``` and kill the script if ```iCamera``` was fast enough to launch it before we renamed it.  

```watch_up.sh``` will then proceed to flash the main partitions directly, instead of doing what the stock script does, which is to flash the images to backup partitions, and then let the bootloader flash the main partitions upon reboot, since this process is currently broken when using the loading the kernel from the micro sd card, which we do.


Once the partitions have been flashed, we reboot the camera, and the FW upgrade is complete.
