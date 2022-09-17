#!/opt/wz_mini/bin/bash
set -e
PATH=$PATH:/opt/wz_mini/tmp/.bin

cd /tmp

# Make a copy to patch
cp /system/bin/iCamera iCamera

Version=""

# Verify the iCamera version is supported
MD5Sum=$(md5sum iCamera | awk '{print $1}')
if [[ "$MD5Sum" == "04b90d6d77be72a4dd8c18da4b31946a" ]] ; then
        Version="4.61.0.1"
fi

if [[ "$MD5Sum" == "b1c96d966226d76db86c96ecdfdd79e9" ]] ; then
        Version="4.36.9.139"
fi

if [ -z "$Version" ] ; then
        echo "Unsupported version. MD5sum: $MD5Sum";
        exit 1
fi


# Check to see if the patched version is installed and is up to date
if [ -f /opt/wz_mini/usr/bin/iCamera.patched ] ; then
	# Check the build date. (this check may be brittle?)
	OriginalDate=$(strings /system/bin/iCamera | grep Build -A 1 | tail -n 1)
	PatchedDate=$(strings /opt/wz_mini/usr/bin/iCamera.patched | grep Build -A 1 | tail -n 1)

	if [[ "$OriginalDate" == "$PatchedDate" ]] ; then
		echo "Patch already applied to current iCamera version."
		exit 0
	fi

	echo "Patched iCamera binary differs in build date. ($OriginalDate vs $PatchedDate)."
	echo "Patch is now reapplying."
fi


# Patch out the calls to test cloud url, which calls that DN function
#  This isn't strictly necessary, though it will cause iCamera to constantly retry the tests and spam the iCamera outputs with messages like
#    DN:854]err: (getaddrinfo) fail:-2(Name or service not known), (domain: www.google.com
#  so we'll comment these calls here to make it hush up
function patch_out_calls_to_test_cloud_url() {
        [[ "$Version" == "4.61.0.1" ]] && Address="0x603b0 0x602d4"
        [[ "$Version" == "4.36.9.139" ]] && Address="0x89938 0x89858"

        echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

        for i in  $Address ; do
                echo -e "\nOriginal at $i"
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

                echo "Patched"
                printf '\x00\x00\x00\x00' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
        done
}


# Patch out the threadpool_add_job calls for net-valid and upload-rebootlog, and dongle send
function patch_out_jobs_after_connect () {
        [[ "$Version" == "4.61.0.1" ]]   && Address="$(seq 0x070d0 4 0x07114)"
        [[ "$Version" == "4.36.9.139" ]] && Address="$(seq 0x7b184 4 0x7b1cc)"

        echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

        # Everything up until the last branch instruction
        for i in $Address ; do
                echo -e "\nOriginal at $i"
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

                echo "Patched"
                # noop
                printf '\x00\x00\x00\x00' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
        done
}


# When our calls to DN check cloud url fails, we run into the code that calls funky_network_function(0). We don't want that. So noop all this out
# All the code that sets DAT_005e4d54=0, prints debug message, and calls funky_network_func(0) is nooped out here.
# This fixes the network from going back to the idle state and bouncing everything
#  The call to print debug message could probably be left intact... we don't actually prevent 005e4d50=0  though..
function patch_out_network_reset_to_idle () {
        [[ "$Version" == "4.61.0.1" ]]   && Address="$(seq 0x6041c 4 0x6045c)"
        [[ "$Version" == "4.36.9.139" ]] && Address="$(seq 0x899a4 4 0x899e4)"

        echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

        for i in $Address ; do
                echo -e "\nOriginal at $i"
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

                echo "Patched"
                # noop
                printf '\x00\x00\x00\x00' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
        done
}


# For some reason on 4.36.9.139, iCamera starts the code_test section which just constantly lists /tmp over and over every 10 seconds.
# I don't know why this is getting triggered, so I'm going to patch this out from being called.
function patch_out_code_test_enable() {
        [[ "$Version" == "4.61.0.1" ]]   && return;  # No need to do this as it doesn't seem to be a problem
        [[ "$Version" == "4.36.9.139" ]] && Address="0x7dfcc"

        echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

        for i in $Address ; do
                echo -e "\nOriginal at $i"
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

                echo "Patched"
                # noop
                printf '\x00\x00\x00\x00' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
                dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
        done
}

patch_out_calls_to_test_cloud_url
patch_out_jobs_after_connect
patch_out_network_reset_to_idle
patch_out_code_test_enable

echo -en "\n\nPatching done. MD5 hash: "
md5sum iCamera


# Place it on the SD card
cp iCamera  /opt/wz_mini/usr/bin/iCamera.patched

# Patch the iCamera script to use the patched executable
sed -i 's/\/system\/bin\/iCamera/\/opt\/wz_mini\/usr\/bin\/iCamera.patched/' /opt/wz_mini/usr/bin/iCamera

