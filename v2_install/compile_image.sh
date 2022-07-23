#!/bin/bash

UA_STRING="Mozilla/5.0 (Macintosh; Intel Mac OS X 12_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Safari/605.1.15"
DL_URL=$(wget --header="Accept: text/html" --user-agent="$UA_STRING" -qO- https://support.wyze.com/hc/en-us/articles/360024852172-Release-Notes-Firmware | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep /v2/ |   sort -t . -k2r,5 | grep demo | head -1)
PAN_DL_URL=$(wget --header="Accept: text/html" --user-agent="$UA_STRING" -qO- https://support.wyze.com/hc/en-us/articles/360024852172-Release-Notes-Firmware | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep /pan/ |   sort -t . -k2r,5 | grep demo | head -1)

echo "checking for tools"
command -v wget >/dev/null 2>&1 || { echo >&2 "wget is not installed.  Aborting."; exit 1; }
command -v mkimage >/dev/null 2>&1 || { echo >&2 "mkimage is not installed.  Aborting."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is not installed.  Aborting."; exit 1; }

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
	elif [[ "$1" == "" ]]; then
		echo "build for v2"
		wget $DL_URL -O ./v2_ro/demo.zip
	fi
fi

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

echo "remove temporary work directory"
rm -rf v2_ro

echo "demo.bin ready.  Please copy demo.bin to your memory card"
