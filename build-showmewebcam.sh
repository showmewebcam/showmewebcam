#!/bin/bash

ORIGIN_PI_CAM="raspberrypi0cam" # renamed from raspberrypi0w
target_defconfig="$ORIGIN_PI_CAM"_defconfig

BOARDNAME=$1

case "$BOARDNAME" in
        raspberrypi0cam)
			echo "Building for Universal Pi0 (Wireless and Non-wireless) board"
        ;;
        *)
			echo "usage: BUILDROOT_DIR=../buildroot $0 (boardname)"
			echo "boardname: raspberrypi0cam"
			exit 1
        ;;
esac

BR2_EXTERNAL="$(pwd)" make O="$(pwd)/output/$BOARDNAME" -C "$BUILDROOT_DIR" "$target_defconfig"
make -s -C "output/$BOARDNAME" all
