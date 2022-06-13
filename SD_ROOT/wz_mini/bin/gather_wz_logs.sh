#!/bin/sh

create_dir() {
	echo "creating gather dir"
	mkdir /opt/wz_mini/tmp/log_gather
}

if [ -d /opt/wz_mini/tmp/log_gather ] ; then
	echo "gather dir already present, deleting."
	rm -rf /opt/wz_mini/tmp/log_gather
	create_dir
else
create_dir
fi

#cat * | grep 2C | sed 's/^.*\(RTSP_PASSWORD=\).*$/\1/' | sed 's/-U[^-P]*//'
echo "copy wz_mini logs"
cp /opt/wz_mini/log/* /opt/wz_mini/tmp/log_gather/

echo "gather impdbg"
impdbg --enc_info > /opt/wz_mini/tmp/log_gather/enc_info

echo "gather logcat"
logcat -d > /opt/wz_mini/tmp/log_gather/logcat

echo "gather callback"
logread | grep callback > /opt/wz_mini/tmp/log_gather/callback.log

echo "gather local_sdk"
logread | grep local_sdk > /opt/wz_mini/tmp/log_gather/local_sdk.log

echo "gather /dev"
ls -l /dev > /opt/wz_mini/tmp/log_gather/dev.log

echo "gather df"
df -h > /opt/wz_mini/tmp/log_gather/df.log

echo "gather libcallback logs"
logread | grep "\[command\]" > /opt/wz_mini/tmp/log_gather/libcallback.log

echo "gather process list"
ps -T | sed 's/-U[^-P]*//' > /opt/wz_mini/tmp/log_gather/ps.log

echo "gather mounts"
mount > /opt/wz_mini/tmp/log_gather/mount.log

echo "gather mmc"
logread | grep -E "mmc|storage_dev|playback_dev|tf_prepare" > /opt/wz_mini/tmp/log_gather/mmc.log

echo "gather lsmod"
lsmod > /opt/wz_mini/tmp/log_gather/kmod.log

echo "gather app.ver"
cp /system/bin/app.ver /opt/wz_mini/tmp/log_gather/system_app.ver

if [ -f /tmp/sd_check_result.txt ]; then
	echo "copy sd_check_result.txt"
	cp /tmp/sd_check_result.txt /opt/wz_mini/tmp/log_gather/sd_check_result.txt
fi

echo "compress to /media/mmc/log_gather_$(date +"%F_T%H%M").tar.gz"
tar -czf /media/mmc/log_gather_$(date +"%F_T%H%M").tar.gz -C /opt/wz_mini/tmp log_gather/

echo "cleanup, remove gather dir"
rm -rf /opt/wz_mini/tmp/log_gather
