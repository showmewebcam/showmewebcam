#!/bin/sh

set -u
set -e

mkdir -p "${TARGET_DIR}"/etc/systemd/system/getty.target.wants
# Add a console on tty1
#ln -sf /usr/lib/systemd/system/getty@.service "${TARGET_DIR}"/etc/systemd/system/getty.target.wants/getty@tty1.service

# Add a console on ttyAMA0
ln -sf /usr/lib/systemd/system/serial-getty@.service "${TARGET_DIR}"/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service

# Add wireless wpa for wlan0
#ln -sf /usr/lib/systemd/system/wpa_supplicant@.service "${TARGET_DIR}"/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

if ! grep -qE '/var' "${TARGET_DIR}/etc/fstab"; then
	echo 'tmpfs           /var            tmpfs   rw,mode=1777,size=64m' >> "${TARGET_DIR}/etc/fstab"
fi

if ! grep -qE '/boot' "${TARGET_DIR}/etc/fstab"; then
	echo '/dev/mmcblk0p1  /boot           vfat    ro' >> "${TARGET_DIR}/etc/fstab"
fi
