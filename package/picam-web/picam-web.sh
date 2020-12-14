#!/bin/sh

CONF=/boot/camera.txt
TMP=/tmp/camera.txt
CAM=/dev/video0

IP_ADDR="$1"

ifconfig usb0 $IP_ADDR netmask 255.255.255.252 up

cp $CONF $TMP || touch $TMP

mkdir -p /var/www/media
mkdir -p /dev/shm/mjpeg
mknod /var/www/FIFO p
chmod 666 /var/www/FIFO

/opt/rpic-raspimjpeg/raspimjpeg --config /opt/rpic-raspimjpeg/config &

# Need "/"" at the end
/opt/picam-web/picam-web -d "/opt/picam-web/web_root/"

# mount -o remount,rw /boot || { echo "Cannot remount boot as read-write, please inspect and transfer /tmp/camera.txt to /boot manually"; exit 1; }
# cp $TMP $CONF
# sync
# mount -o remount,ro /boot || echo "Warning: Cannot remount boot as read-only."

# rm $TMP
