#!/opt/wz_mini/bin/bash
# Description: Applies the iCamera binary patch to prevent iCamera from restarting the wireless
#   network when it is unable to reach the internet or Wyze's cloud. This should only be used in
#   self-hosted environments as it may break Wyze App functionality.
# Author: Leo Leung <leo@steamr.com>
# Last modified: September 2022
#

set -e
PATH=$PATH:/opt/wz_mini/tmp/.bin

# Firmware version
Version=""

function main() {
	# Handle remove / apply commands or print the usage message.
	if [[ "$1" == "remove" ]] ; then
		remove_patch
		exit
	fi

	if [[ "$1" == "apply" ]] ; then
		apply_patch
		exit
	fi

	echo "Usage: $0 [apply|remove]"
	echo "  Applies the iCamera patch to make it work nice without Wyze Cloud connectivity"
}

function determine_version() {
	# Verify the iCamera version is supported
	MD5Sum=$(md5sum $1 | awk '{print $1}')

	if [[ "$MD5Sum" == "04b90d6d77be72a4dd8c18da4b31946a" ]] ; then
		echo "4.61.0.1"
	elif [[ "$MD5Sum" == "b1c96d966226d76db86c96ecdfdd79e9" ]] ; then
		echo "4.36.9.139"
	elif [[ "$MD5Sum" == "b187239d1881a97d4598798a2035c0f3" ]] ; then
		# v2 camera firmware
		echo "4.9.8.1002"
	else
		echo "Error: Unknown iCamera version with md5sum $MD5Sum"
		exit 1
	fi
}

function apply_patch() {
	# Check to see if the patched version is installed and is up to date
	if [ -f /opt/wz_mini/usr/bin/iCamera.patched ] ; then
		# Check the build date. (this check may be brittle?)
		OriginalDate=$(strings /system/bin/iCamera | grep "Build date" -A 1 | tail -n 1)
		PatchedDate=$(strings /opt/wz_mini/usr/bin/iCamera.patched | grep "Build date" -A 1 | tail -n 1)

		if [[ "$OriginalDate" == "$PatchedDate" ]] ; then
			echo "Patch already applied to current iCamera version."
			exit 0
		fi

		echo "Patched iCamera binary differs in build date. ($OriginalDate vs $PatchedDate)."
		echo "Patch is now reapplying."
	fi

	# Ensure our version works. This exits if it is unsupported.
	Version=$(determine_version /system/bin/iCamera)

	# Working in /tmp
	cd /tmp

	# Make a copy to patch
	cp /system/bin/iCamera iCamera

	# For the T20/v2 cameras, we also have to patch the libwyzeUtils.so library
	[ -f /opt/wz_mini/tmp/.T20 ] && cp /system/lib/libwyzeUtils.so libwyzeUtils.so

	# Apply our patches.
	patch_out_calls_to_test_cloud_url
	patch_out_jobs_after_connect
	patch_out_network_reset_to_idle
	patch_out_code_test_enable
	# v2 specific
	patch_wzutil_testconnectbyurl_skip_check
	patch_v2_led_connect_led

	echo -e "\n\nPatching done."
	md5sum iCamera
	[ -f /opt/wz_mini/tmp/.T20 ] && md5sum libwyzeUtils.so


	# Place it on the SD card and modify the iCamera script to use it.
	cp iCamera  /opt/wz_mini/usr/bin/iCamera.patched
	sed -i 's/\/system\/bin\/iCamera/\/opt\/wz_mini\/usr\/bin\/iCamera.patched/' /opt/wz_mini/usr/bin/iCamera

	# the v2 patched library should be copied to /opt/wz_mini/lib
	if [ -f /opt/wz_mini/tmp/.T20 ]; then
		cp libwyzeUtils.so /opt/wz_mini/lib/libwyzeUtils.so

		# Fix the LD_PRELOAD to use this patched version first.
		# The T20 has 'libcallback_t20.so:libtinyalsa.so.2.0.0'
		sed -i "s/LD_PRELOAD='libcallback_t20.so:libtinyalsa.so.2.0.0'/LD_PRELOAD='\/opt\/wz_mini\/lib\/libwyzeUtils.so:libcallback_t20.so:libtinyalsa.so.2.0.0'/" /opt/wz_mini/usr/bin/iCamera
	fi

	echo "Installed."
}

function remove_patch() {
	echo "Reverting iCamera patch."
	
	# Remove patched iCamera
	if [ -f /opt/wz_mini/usr/bin/iCamera.patched ] ; then
		rm -v /opt/wz_mini/usr/bin/iCamera.patched
	fi

	# Remove patched libwyzeUtils
	if [ -f /opt/wz_mini/lib/libwyzeUtils.so ] ; then
		rm -v /opt/wz_mini/lib/libwyzeUtils.so
	fi

	# Ensure iCamera shim script points to /system/bin/iCamera
	if grep -q iCamera.patched /opt/wz_mini/usr/bin/iCamera ; then
		sed -i 's/\/opt\/wz_mini\/usr\/bin\/iCamera.patched/\/system\/bin\/iCamera/' /opt/wz_mini/usr/bin/iCamera
	fi

	# If the libwyzeUtils is referenced for the t20, remove it
	if grep -q libwyzeUtils.so:libcallback_t20.so /opt/wz_mini/usr/bin/iCamera ; then
		sed -i "s/LD_PRELOAD='\/opt\/wz_mini\/lib\/libwyzeUtils.so:libcallback_t20.so:libtinyalsa.so.2.0.0'/LD_PRELOAD='libcallback_t20.so:libtinyalsa.so.2.0.0'/" /opt/wz_mini/usr/bin/iCamera
	fi

	echo "Removed."
}


# Patch out the calls to test cloud url, which calls the DN check function with NOPs
#  This isn't strictly necessary, though it will cause iCamera to constantly retry the tests and spam the iCamera outputs with messages like
#    DN:854]err: (getaddrinfo) fail:-2(Name or service not known), (domain: www.google.com
#  so we'll comment these calls here to make it hush up
function patch_out_calls_to_test_cloud_url() {
	[[ "$Version" == "4.61.0.1" ]] && Address="0x603b0 0x602d4"
	[[ "$Version" == "4.36.9.139" ]] && Address="0x89938 0x89858"
	[[ "$Version" == "4.9.8.1002" ]] && return; # Not in v2

	echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

	for i in  $Address ; do
		echo -e "\nOriginal at $i"
		dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

		echo "Patched"
		printf '\x00\x00\x00\x00' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
		dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
	done
}


# Patch out the threadpool_add_job calls for net-valid and upload-rebootlog, and dongle send calls with NOPs
function patch_out_jobs_after_connect () {
	[[ "$Version" == "4.61.0.1" ]]   && Address="$(seq 0x070d0 4 0x07114)"
	[[ "$Version" == "4.36.9.139" ]] && Address="$(seq 0x7b184 4 0x7b1cc)"
	[[ "$Version" == "4.9.8.1002" ]] && Address="$(seq 0x089c8 4 0x08a30)"

	echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

	# Everything up until the last branch instruction
	for i in $Address ; do
		echo -e "\nOriginal at $i"
		dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

		echo "Patched"
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
	[[ "$Version" == "4.9.8.1002" ]] && return; # this is in the libwyzeUtils.so library, I think. Can't find similar code

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


# Patch out code_test trigger with NOPs
# For some reason on 4.36.9.139, iCamera starts the code_test section which just constantly lists /tmp over and over every 10 seconds.
# I don't know why this is getting triggered, so I'm going to patch this out from being called.
function patch_out_code_test_enable() {
	[[ "$Version" == "4.61.0.1" ]]   && return;  # No need to do this as it doesn't seem to be a problem
	[[ "$Version" == "4.36.9.139" ]] && Address="0x7dfcc"
	[[ "$Version" == "4.9.8.1002" ]] && return;  # not in the v2 firmware, I think. 

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

# Patch libwyzeUtils.so so that the testconnectbyurl function always returns true, regardless of whether
# the cloud is available or not.
function patch_wzutil_testconnectbyurl_skip_check() {
	# For the v2 firmware using the libwyzeUtils.so library only.
	[ ! -f /opt/wz_mini/tmp/.T20 ]   && return  # Only on the v2
	[[ "$Version" == "4.61.0.1" ]]   && return
	[[ "$Version" == "4.36.9.139" ]] && return
	[[ "$Version" != "4.9.8.1002" ]] && return  # Only supports 4.9.8.1002

	echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

	# BEQ $4 $0 0x5E branches to the 'URL is null' section of the code which returns -1
	# We want to go there and return 0 always instead. So let's blez (always true on an unsigned int)
	# and patch the -1 to 0

	i="0x203d0" # should have content: 5e 00 80 10, (BEQ $4 $0 0x5E)
	echo -e "\nOriginal at $i"
	dd if=libwyzeUtils.so bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

	echo "Patched"  # patch with 5e 00 81 04  (BLEZ $4 0x5E)
	printf '\x5e\x00\x81\x04' | dd conv=notrunc of=libwyzeUtils.so bs=1 seek=$(($i)) 2> /dev/null
	dd if=libwyzeUtils.so bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

	# At 3056c, we load -1 to s0, which is our return code. fix this to 0
	i="0x2056c" # should have content: ff ff 10 24
	echo -e "\nOriginal at $i"
	dd if=libwyzeUtils.so bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd

	echo "Patched" # patch with 00 00 10 24, should load s0 to 0 before returning
	printf '\x00\x00\x10\x24' | dd conv=notrunc of=libwyzeUtils.so bs=1 seek=$(($i)) 2> /dev/null
	dd if=libwyzeUtils.so bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
}

# Patch LED state in iCamera binary so LED stays off after connecting
# Applies only to the v2
function patch_v2_led_connect_led () {
	# Applies only to this particular firmware in the v2.
	[[ "$Version" != "4.9.8.1002" ]] && return

	echo -e "\n\n====> Calling ${FUNCNAME[0]}\n"

	# Use the big NOP space from patch_out_jobs_after_connect to call led_ctrl_run_action_by_state(5)

	i="0x089c8"
	# li 5 a0
	printf '\x05\x00\x04\x24' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
	dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd


	i="0x089cc"
	# jal led_ctrl_run_action_by_state
	printf '\xcc\xc4\x10\x0c' | dd conv=notrunc of=iCamera bs=1 seek=$(($i)) 2> /dev/null
	dd if=iCamera bs=1 count=4 skip=$(($i)) 2>/dev/null | xxd
}


main "$@"

