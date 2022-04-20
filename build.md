# process


build kernel with initramfs

initramfs ```/etc/init``` runs ```exec busybox switch_root /v3 /opt/wz_mini/etc/init.d/v3_init.sh```

```/opt/wz_mini/etc/init.d/v3_init.sh``` 

bind replace ```/etc/init.d/inittab``` with our own version that has rcS located at ```/opt/wz_mini/tmp/.storage/rcS```

bind replaces ```/etc/profile```

mounts ```/tmp``` and ```/run```

mounts ```/system```
bind replaces ```/system/bin/factorycheck```, this program unmounts the binds that we do later in the file, its a debug program.
bind replaces ```/etc/fstab```

creates wz_mini's workplace directory at ```/opt/wz_mini/tmp```

copies the stock ```/etc/init.d/rcS``` to the workplace directory

modifies the stock rcS, adds ```set -x``` debug mode and injects the following script ```/opt/wz_mini/etc/init.d/v3_post.sh``` ro run

bind replaces ```/etc/shadow``` to change the stock password

checks to see if the swap archive is present at ```/opt/wz_mini/swap.gz```, if it is, extracts it, then mkswap's it, and drops the vm cache.

check to see if the ```/opt/wz_mini/usr/share/terminfo``` directory is present, if not, extract the terminfo files for console programs

mounts ```/configs``` to check if the ```.ssh``` dir is present, a requirement for the dropbear ssh server

checks to see if ```/opt/wz_mini/run_mmc.sh``` has debug mode enabled, if it does, skip loading ```/system/bin/app_init.sh``` and ```/media/mmc/wz_mini/run_mmc.sh```

run ```/media/mmc/wz_mini/run_mmc.sh```, but delay execution for 30 seconds, enough time for WiFi or wired ethernet/usb to load and connect successfully to the internet

runs ```/linuxrc``` to kick off the stock boot process

our modified inittab runs from ```/opt/wz_mini/tmp/.storage/rcS```, we have enabled set -x debug info, added ```/opt/wz_mini/bin``` and ```/opt/wz_mini/lib``` to the system PATH's, and added ```/opt/wz_mini/etc/init.d/v3_post.sh``` to run before ```/system/init/app_init.sh``` runs.

```/opt/wz_mini/etc/init.d/v3_post.sh``` checks if ```run_mmc.sh``` has the RTSP server enabled, and if it does, we copy ```/system/bin/iCamera``` to our workplace directory at ```/opt/wz_mini/tmp/.storage/```

bind replace ```/system/bin/iCamera```

our version of iCamera is a script which injects the libcallback.so library as LD_PRELOAD to hook the Audio and Video to the RTSP Server, calling iCamera from it's new home at ```/opt/wz_mini/tmp/.storage/```

we then load the video loopback driver from ```/opt/wz_mini/lib/modules/v4l2loopback.ko```

```/system/bin/app_init.sh``` loads the stock system software
