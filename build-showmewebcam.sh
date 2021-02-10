#!/bin/bash

# Allow to overwrite default buildroot location
BUILDROOT_DIR=${BUILDROOT_DIR:-buildroot}

if [ ! -d "$BUILDROOT_DIR" ]; then
  echo "Please provide a valid buildroot directory, either by using BUILDROOT_DIR or by renaming it to \"buildroot\""
  exit 1
fi

export BOARDNAME=$1

case "$BOARDNAME" in
  raspberrypi0)
  ;;
  raspberrypi0w)
  ;;
  raspberrypi4)
  ;;
  *)
    echo "usage: BUILDROOT_DIR=buildroot $0 (boardname)"
    echo "boardname: raspberrypi0, raspberrypi0w, raspberrypi4"
    exit 1
  ;;
esac

# Merge custom buildroot configurations
CONFIG_="BR2" KCONFIG_CONFIG="configs/${BOARDNAME}_defconfig" "$BUILDROOT_DIR/support/kconfig/merge_config.sh" -m -r configs/config "configs/$BOARDNAME"
sed "1i ### DO NOT EDIT, this file was automatically generated\n" -i "configs/${BOARDNAME}_defconfig"

# Merge kernel configurations
if [ -f "board/linux-${BOARDNAME}.config" ]; then
  KCONFIG_CONFIG="board/linux.config" "$BUILDROOT_DIR/support/kconfig/merge_config.sh" -m -r board/linux-base.config "board/linux-${BOARDNAME}.config"
else
  cp board/linux-base.config board/linux.config
fi
sed "1i ### DO NOT EDIT, this file was automatically generated\n" -i board/linux.config

# Create full buildroot configuration
BR2_EXTERNAL="$(pwd)" make O="$(pwd)/output/$BOARDNAME" -C "$BUILDROOT_DIR" "${BOARDNAME}_defconfig"

# Build
make -C "output/$BOARDNAME" all
