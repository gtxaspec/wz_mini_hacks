#!/bin/sh

#custom for V2

set -x

ACTION=$1

KERNEL_OFFSET=$((64))
ROOTFS_OFFSET=$((2097216))
DRIVER_OFFSET=$((5570624))
APPFS_OFFSET=$((6225984))

if [ "$ACTION" = "unpack" ]; then
    DEMO_IN=$2
    OUT_DIR=$3

    dd if=${DEMO_IN} of=$OUT_DIR/kernel.bin skip=$KERNEL_OFFSET count=$(($ROOTFS_OFFSET-$KERNEL_OFFSET)) bs=1
    md5sum $OUT_DIR/kernel.bin

    dd if=${DEMO_IN} of=$OUT_DIR/rootfs.bin skip=$ROOTFS_OFFSET count=$(($DRIVER_OFFSET-$ROOTFS_OFFSET)) bs=1
    md5sum $OUT_DIR/rootfs.bin

    dd if=${DEMO_IN} of=$OUT_DIR/driver.bin skip=$DRIVER_OFFSET count=$(($APPFS_OFFSET-$DRIVER_OFFSET)) bs=1
    md5sum $OUT_DIR/driver.bin

    if [ "$(uname -s)" = "Darwin" ]; then
    IMAGE_END=$(($(stat -f %z ${DEMO_IN})))
    else
    IMAGE_END=$(($(stat -c %s ${DEMO_IN})))
    fi

    dd if=${DEMO_IN} of=$OUT_DIR/appfs.bin  skip=$APPFS_OFFSET count=$(($IMAGE_END-$APPFS_OFFSET)) bs=1
    md5sum $OUT_DIR/appfs.bin

elif [ "$ACTION" = "pack" ]; then
    TMP_DIR=$2
    DEMO_OUT=$3

    #need to pad kernel is its smaller than the stock kernel size, 2097152 bytes
    dd if=/dev/zero of=$TMP_DIR/kernel.bin bs=1 count=1 seek=2097151

    #only run mkimage if cat succeeds, otherwise it's possible that a bad image is created
    cat $TMP_DIR/kernel.bin $TMP_DIR/rootfs.bin $TMP_DIR/driver.bin $TMP_DIR/appfs.bin > $TMP_DIR/flash.bin && \
    mkimage -A MIPS -O linux -T firmware -C none -a 0 -e 0 -n jz_fw -d $TMP_DIR/flash.bin $DEMO_OUT

else
    echo "Unknown action '$ACTION'"
fi
