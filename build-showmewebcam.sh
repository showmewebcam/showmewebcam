#!/bin/bash

set -x

# Allow to overwrite default buildroot location
BUILDROOT_DIR=${BUILDROOT_DIR:-buildroot}

if [ ! -d "$BUILDROOT_DIR" ]; then
  echo "Please provide a valid buildroot directory, either by using BUILDROOT_DIR or by renaming it to \"buildroot\""
  exit 1
fi

export BOARDNAME=$1
shift

case "$BOARDNAME" in
  raspberrypi0)
    ;;
  raspberrypi0_2)
    ;;
  raspberrypi4)
    ;;
  *)
    echo "usage: BUILDROOT_DIR=buildroot $0 (boardname) [component]"
    echo "boardname: raspberrypi0, raspberry0_2, raspberrypi4"
    exit 1
  ;;
esac

# Add overridden buildroot packages
cp -R package-override/* "$BUILDROOT_DIR/package"

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
# Pass the args as-is, don't worry about the globbing
if [ $# -ge 1 ] ; then 
  make -C "output/$BOARDNAME" "$@"
else
  make -C "output/$BOARDNAME" all
fi
