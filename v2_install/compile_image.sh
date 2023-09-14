#!/bin/bash

UA_STRING="Mozilla/5.0 (Macintosh; Intel Mac OS X 12_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Safari/605.1.15"
DL_URL=$(wget --header="Accept: text/html" --user-agent="$UA_STRING" -qO- https://support.wyze.com/hc/en-us/articles/360024852172-Release-Notes-Firmware | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep /v2/ |   sort -t . -k2r,5 | grep demo | head -1)
PAN_DL_URL=$(wget --header="Accept: text/html" --user-agent="$UA_STRING" -qO- https://support.wyze.com/hc/en-us/articles/360024852172-Release-Notes-Firmware | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep /pan/ |   sort -t . -k2r,5 | grep demo | head -1)

tools() {
echo "checking for tools"
command -v wget >/dev/null 2>&1 || { echo >&2 "wget is not installed.  Aborting."; exit 1; }
command -v mkimage >/dev/null 2>&1 || { echo >&2 "mkimage is not installed.  Aborting."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is not installed.  Aborting."; exit 1; }
echo "tools OK"
}

cleanup() {
local version="${1:-firmware}"

echo "saving original firmware"
mv ./v2_ro/demo*.zip "./demo_${version// /_}-orig.zip"

echo "removing temporary work directory"
rm -rf v2_ro
}

download(){
rm -f demo.bin

echo "create temporary work directory"
mkdir v2_ro

echo "check for local zip"
if [ -f demo.zip ]; then
	echo "local archive found"
	mv demo.zip ./v2_ro/
else
	echo "local archive not found"
	echo "downloading latest firmware"
	if [[ "$1" == "pan" ]]; then
		echo "build for pan"
		wget $PAN_DL_URL -O ./v2_ro/demo.zip
	else
		echo "build for v2"
		wget $DL_URL -O ./v2_ro/demo.zip
	fi
fi

# check the firmware to see if it's supported
local version_found=""
if [[ $(md5sum ./v2_ro/demo*.zip) == *"a69b6d5ffdbce89463fa83f7f06ec10b"* ]]; then
	version_found="v2 4.9.8.1002"
elif [[ $(md5sum ./v2_ro/demo*.zip) == *"91793d32fd797a10df572f4f5d72bc55"* ]]; then
	version_found="pan v1 4.10.8.1002"
elif [[ $(md5sum ./v2_ro/demo*.zip) == *"68706635fadc12b98c18c4b9540b320f"* ]]; then
	version_found="pan v1 4.10.9.1433"
elif [[ $(md5sum ./v2_ro/demo*.zip) == *"fafc26b815e0053c81ff796109616858"* ]]; then
	version_found="pan v1 4.10.9.1472"
elif [[ $(md5sum ./v2_ro/demo*.zip) == *"27faa1a01d9632a2c79c214632376ad9"* ]]; then
	version_found="pan v1 4.10.9.1574"
elif [[ $(md5sum ./v2_ro/demo*.zip) == *"273d58afbb0ea9550a8f15375f4681d2"* ]]; then
	version_found="pan v1 4.10.9.1851"
else
	cleanup
	echo "md5sum failed check, please supply a supported demo.zip file"
	exit 1
fi
echo "$version_found"

echo "extracting firmware to temporary work directory"
unzip v2_ro/demo*.zip -d ./v2_ro/

echo "create firmware directory"
mkdir v2_ro/fw_dir

echo "unpack stock firmware image"
./fw_tool.sh unpack v2_ro/demo*.bin v2_ro/fw_dir

echo "replace factory kernel"
cp v2_kernel.bin v2_ro/fw_dir/kernel.bin

echo "pack firmware image with new kernel"
./fw_tool.sh pack v2_ro/fw_dir demo.bin

cleanup "$version_found"

# check to see if the modified demo.bin has been created
if [ ! -f "demo.bin" ]; then
  echo "demo.bin was not created.  Aborting."
  exit 1
else
  echo "demo.bin ready for $version_found.  Please copy demo.bin to your memory card"
fi

}


read -r -p "wz_mini: this will download the latest firmware version from the vendor and compile a modified demo.bin.  Are you sure? [y/N]" response
			case "$response" in
			[yY][eE][sS]|[yY])
			tools
			download $1
			;;
		        *)
			echo "User declined, exit"
	        	;;
		    esac
