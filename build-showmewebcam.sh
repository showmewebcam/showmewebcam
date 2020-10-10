#!/bin/bash

export BOARD_NAME="raspberrypi4cam"
target_defconfig="$BOARD_NAME"_defconfig

case "$1" in
        raspberrypi*)
			target_defconfig="$1_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$BOARD_NAME" "board/$1"
			cp -f "configs/$BOARD_NAME"_defconfig "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $BOARD_NAME defconfig" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/raspberrypi0cam/board\/$1/g" -i "$target_defconfig_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2708-rpi-zero/g" -i "$target_defconfig_loc"
            ;;
        *)
			target_defconfig="$BOARD_NAME"_defconfig
esac

export BR2_EXTERNAL="$(pwd)"
make -C ../buildroot "$target_defconfig"
make -C ../buildroot all
