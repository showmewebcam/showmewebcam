#!/bin/sh

set -u
set -e

# Add a console on tty1
mkdir -p "${TARGET_DIR}"/etc/systemd/system/getty.target.wants
ln -sf /usr/lib/systemd/system/getty@.service "${TARGET_DIR}"/etc/systemd/system/getty.target.wants/getty@tty1.service

# Add wireless wpa for wlan0
ln -sf /usr/lib/systemd/system/wpa_supplicant@.service "${TARGET_DIR}"/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
