#!/bin/sh

INTERFACE=usb0
if [ -d "/sys/class/net/${INTERFACE}/" ] ; then
  echo "Configuring USB network interface link-local address"
  /usr/sbin/avahi-autoipd -c "$INTERFACE" || /usr/sbin/avahi-autoipd "$INTERFACE" --no-chroot
fi
