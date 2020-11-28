#!/bin/bash

ORIGIN_PI_CAM="raspberrypi0cam" # renamed from raspberrypi0w
target_defconfig="$ORIGIN_PI_BOARD"_defconfig

BOARDNAME=$1

case "$BOARDNAME" in
        raspberrypi4)
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$ORIGIN_PI_CAM" "board/$BOARDNAME"

			### Modify defconfig ###
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			cp -f "configs/$ORIGIN_PI_CAM"_defconfig "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM defconfig" -i "$target_defconfig_loc"
			# change architecture
			sed "s/BR2_arm1176jzf_s/BR2_cortex_a72/g" -i "$target_defconfig_loc"
			# add Pi 4 firmware
			sed "s/BR2_PACKAGE_RPI_FIRMWARE=y/BR2_PACKAGE_RPI_FIRMWARE=y\nBR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI4=y/g" -i "$target_defconfig_loc"
			# change kernel to 4.19 for Pi4 OTG to work
			sed "s/BR2_KERNEL_HEADERS_5_4/BR2_KERNAL_HEADERS_4_19/g" -i "$target_defconfig_loc"
			sed "s/c5e512a329ac7a0bfdd5f53477f4300723618db5/64d0a9870ac14d5eb5253f67d984ae348eec1393/g" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/raspberrypi0cam/board\/$BOARDNAME/g" -i "$target_defconfig_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2711-rpi-4-b/g" -i "$target_defconfig_loc"
			# change 
			sed "s/linux.config/linux-${BOARDNAME}.config/g" -i "$target_defconfig_loc"

			### Modify linux.config ###
			target_linuxconfig="linux-${BOARDNAME}.config"
			target_linuxconfig_loc="board/$BOARDNAME/$target_linuxconfig"
			cp -f "board/$ORIGIN_PI_CAM/linux.config" "$target_linuxconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM linux.config" -i "$target_linuxconfig_loc"
			# Change architecture 
			sed "s/CONFIG_ARCH_MULTI_V6=y/\# CONFIG_ARCH_MULTI_V6 is not set/g" -i "$target_linuxconfig_loc"
			sed "s/\# CONFIG_ARCH_MULTI_V7 is not set/CONFIG_ARCH_MULTI_V7=y\nCONFIG_ARCH_MULTI_V6_V7=y/g" -i "$target_linuxconfig_loc"
			sed "s/\# CONFIG_LOCALVERSION_AUTO is not set/CONFIG_LOCALVERSION="-v7l"/g" -i "$target_linuxconfig_loc"

			### Modify genimage ###
			target_genimage="genimage-${BOARDNAME}.cfg"
			target_genimage_loc="board/$BOARDNAME/$target_genimage"
			cp -f "board/$ORIGIN_PI_CAM/genimage-raspberrypi0cam.cfg" "$target_genimage_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM genimage-raspberrypi0cam.cfg" -i "$target_genimage_loc"
			# Change change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2711-rpi-4-b/g" -i "$target_genimage_loc"
			# Remove bootcode.bin
			sed '/bootcode.bin/d' -i "$target_genimage_loc"
        ;;
        raspberrypi0)
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
        raspberrypi0w)
			target_defconfig="$ORIGIN_PI_CAM"_defconfig

        ;;
        *)
			echo "usage: BUILDROOT_DIR=../buildroot $0 (boardname)"
			echo "boardname: raspberrypi0, raspberrypi0w, raspberrypi4"
			exit 1
        ;;
esac

BR2_EXTERNAL="$(pwd)" make O="$(pwd)/output/$BOARDNAME" -C "$BUILDROOT_DIR" "$target_defconfig"
make -C "output/$BOARDNAME" all
