#!/bin/bash

ORIGIN_PI_CAM="raspberrypi0cam" # renamed from raspberrypi0cam
target_defconfig="$ORIGIN_PI_CAM"_defconfig

BOARDNAME=$1

case "$BOARDNAME" in
        raspberrypi4)
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$ORIGIN_PI_CAM" "board/$BOARDNAME"

			### generate defconfig ###
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			cat "configs/defaultpi4_defconfig" "configs/${ORIGIN_PI_CAM}_defconfig" > "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM defconfig" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/$ORIGIN_PI_CAM/board\/$BOARDNAME/g" -i "$target_defconfig_loc"

			### generate linuxconfig ###
			target_linuxconfig="${BOARDNAME}.config"
			target_linuxconfig_loc="board/$BOARDNAME/$target_linuxconfig"
			cat "board/$ORIGIN_PI_CAM/default${BOARDNAME}.config" "board/$ORIGIN_PI_CAM/${ORIGIN_PI_CAM}.config" > "$target_linuxconfig_loc"

			### generate genimage ###
			target_genimage="genimage-${BOARDNAME}.cfg"
			target_genimage_loc="board/$BOARDNAME/$target_genimage"
			cp -f "board/$ORIGIN_PI_CAM/genimage-${ORIGIN_PI_CAM}.cfg" "$target_genimage_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM/genimage-${ORIGIN_PI_CAM}.cfg" -i "$target_genimage_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2711-rpi-4-b/g" -i "$target_genimage_loc"
			# change boot size
			sed "s/size = 16M/size = 32M/g" -i "$target_genimage_loc"
			# remove bootcode.bin
			sed '/bootcode.bin/d' -i "$target_genimage_loc"
        ;;
        raspberrypi0)
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$ORIGIN_PI_CAM" "board/$BOARDNAME"

			### generate defconfig ###
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			cat "configs/defaultpi0w_defconfig" "configs/${ORIGIN_PI_CAM}_defconfig" > "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM defconfig" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/$ORIGIN_PI_CAM/board\/$BOARDNAME/g" -i "$target_defconfig_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2708-rpi-zero/g" -i "$target_defconfig_loc"

			### generate linuxconfig ###
			target_linuxconfig="${BOARDNAME}.config"
			target_linuxconfig_loc="board/$BOARDNAME/$target_linuxconfig"
			cat "board/$ORIGIN_PI_CAM/default${BOARDNAME}.config" "board/$ORIGIN_PI_CAM/${ORIGIN_PI_CAM}.config" > "$target_linuxconfig_loc"

			### generate genimage ###
			target_genimage="genimage-${BOARDNAME}.cfg"
			target_genimage_loc="board/$BOARDNAME/$target_genimage"
			cp -f "board/$ORIGIN_PI_CAM/genimage-${ORIGIN_PI_CAM}.cfg" "$target_genimage_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM/genimage-$ORIGIN_PI_CAM.cfg" -i "$target_genimage_loc"
			# change dts file
			sed "s/bcm2708-rpi-zero-w/bcm2708-rpi-zero/g" -i "$target_genimage_loc"
        ;;
        raspberrypi0w)
			# post-image.sh will gen corresponding image depend on basename path
			ln -sfrn "board/$ORIGIN_PI_CAM" "board/$BOARDNAME"

			### generate defconfig ###
			target_defconfig="${BOARDNAME}_defconfig"
			target_defconfig_loc="configs/$target_defconfig"
			cat "configs/defaultpi0w_defconfig" "configs/${ORIGIN_PI_CAM}_defconfig" > "$target_defconfig_loc"

			sed "1i ### DO NOT EDIT, this is generated file from $ORIGIN_PI_CAM defconfig" -i "$target_defconfig_loc"
			# change path
			sed "s/board\/$ORIGIN_PI_CAM/board\/$BOARDNAME/g" -i "$target_defconfig_loc"
			
			### generate linuxconfig ###
			target_linuxconfig="${BOARDNAME}.config"
			target_linuxconfig_loc="board/$BOARDNAME/$target_linuxconfig"
			cat "board/$ORIGIN_PI_CAM/default${BOARDNAME}.config" "board/$ORIGIN_PI_CAM/${ORIGIN_PI_CAM}.config" > "$target_linuxconfig_loc"

			### generate genimage ###
			target_genimage="genimage-${BOARDNAME}.cfg"
			target_genimage_loc="board/$BOARDNAME/$target_genimage"
			cp -f "board/$ORIGIN_PI_CAM/genimage-${ORIGIN_PI_CAM}.cfg" "$target_genimage_loc"
        ;;
        *)
			echo "usage: BUILDROOT_DIR=../buildroot $0 (boardname)"
			echo "boardname: raspberrypi0, raspberrypi0w, raspberrypi4"
			exit 1
        ;;
esac

BR2_EXTERNAL="$(pwd)" make O="$(pwd)/output/$BOARDNAME" -C "$BUILDROOT_DIR" "$target_defconfig"
make -C "output/$BOARDNAME" all
