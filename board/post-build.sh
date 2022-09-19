#!/bin/bash

set -u
set -e

mkdir -p "${TARGET_DIR}"/etc/systemd/system/getty.target.wants
# Add a console on tty1
#ln -sf /usr/lib/systemd/system/getty@.service "${TARGET_DIR}"/etc/systemd/system/getty.target.wants/getty@tty1.service

# Add a console on ttyAMA0 and enable auto login
ln -sf /usr/lib/systemd/system/serial-getty@.service "${TARGET_DIR}"/etc/systemd/system/getty.target.wants/serial-getty@ttyGS0.service
sed '/^ExecStart=/ s/-o .-p -- ..u./--skip-login --noclear --noissue --login-options "-f root"/' -i "${TARGET_DIR}"/usr/lib/systemd/system/serial-getty@.service

if ! grep -qE '/var' "${TARGET_DIR}/etc/fstab"; then
	echo 'tmpfs           /var            tmpfs   rw,mode=1777,size=64m' >> "${TARGET_DIR}/etc/fstab"
fi

if ! grep -qE '/boot' "${TARGET_DIR}/etc/fstab"; then
	echo '/dev/mmcblk0p1  /boot           vfat    ro' >> "${TARGET_DIR}/etc/fstab"
fi

# Disable fsck on root
sed -ie '/^\/dev\/root/ s/0 1/0 0/' "${TARGET_DIR}/etc/fstab"

# Disable unused services
ln -sf /dev/null "${TARGET_DIR}"/etc/systemd/system/sys-kernel-debug.mount
ln -sf /dev/null "${TARGET_DIR}"/etc/systemd/system/dev-mqueue.mount
ln -sf /dev/null "${TARGET_DIR}"/etc/systemd/system/systemd-update-utmp.service
ln -sf /dev/null "${TARGET_DIR}"/etc/systemd/system/systemd-update-utmp-runlevel.service
ln -sf /dev/null "${TARGET_DIR}"/etc/systemd/system/network.service

# Set os-release file
SHOWMEWEBCAM_VERSION=$(support/scripts/setlocalversion "${BR2_EXTERNAL_PICAM_PATH}")

cat > "${TARGET_DIR}"/usr/lib/os-release <<EOF
NAME="Show-me webcam"
VERSION=${SHOWMEWEBCAM_VERSION}
ID=showmewebcam
VERSION_ID=${SHOWMEWEBCAM_VERSION}
PRETTY_NAME="Show-me webcam ${SHOWMEWEBCAM_VERSION}"
EOF
