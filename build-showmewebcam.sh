#!/bin/bash

ORIGIN_PI_CAM="raspberrypi0cam" # renamed from raspberrypi0w
target_defconfig="$ORIGIN_PI_BOARD"_defconfig

BOARDNAME=$1cam

case "$BOARDNAME" in
        raspberrypi4cam)
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
        ;;
        raspberrypi0cam)
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$ORIGIN_PI_CAM" "board/$BOARDNAME"
			cp -f "configs/$ORIGIN_PI_CAM"_defconfig "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM defconfig" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/raspberrypi0cam/board\/$BOARDNAME/g" -i "$target_defconfig_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2708-rpi-zero/g" -i "$target_defconfig_loc"
        ;;
        raspberrypi0wcam)
			target_defconfig="$ORIGIN_PI_CAM"_defconfig

        ;;
        *)
			echo "usage: BUILDROOT_DIR=../buildroot $0 (boardname)"
			echo "boardname: raspberrypi0, raspberrypi0w, raspberrypi4"
			exit 1
        ;;
esac

BR2_EXTERNAL="$(pwd)" make O="$(pwd)/output/$BOARDNAME" -C "$BUILDROOT_DIR" "$target_defconfig"
make -s -C "output/$BOARDNAME" all