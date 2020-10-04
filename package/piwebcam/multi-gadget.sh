#!/bin/sh
mkdir /sys/kernel/config/usb_gadget/pi4

echo 0x1d6b > /sys/kernel/config/usb_gadget/pi4/idVendor
echo 0x0104 > /sys/kernel/config/usb_gadget/pi4/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/pi4/bcdDevice
echo 0x0200 > /sys/kernel/config/usb_gadget/pi4/bcdUSB

echo 0xEF > /sys/kernel/config/usb_gadget/pi4/bDeviceClass
echo 0x02 > /sys/kernel/config/usb_gadget/pi4/bDeviceSubClass
echo 0x01 > /sys/kernel/config/usb_gadget/pi4/bDeviceProtocol

mkdir /sys/kernel/config/usb_gadget/pi4/strings/0x409
echo 100000000d2386db > /sys/kernel/config/usb_gadget/pi4/strings/0x409/serialnumber
echo "Show-me-webcam Project" > /sys/kernel/config/usb_gadget/pi4/strings/0x409/manufacturer
echo "Show-me-webcam Pi Webcam" > /sys/kernel/config/usb_gadget/pi4/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/pi4/configs/c.2
mkdir /sys/kernel/config/usb_gadget/pi4/configs/c.2/strings/0x409
echo 500 > /sys/kernel/config/usb_gadget/pi4/configs/c.2/MaxPower
echo "Show-me-webcam Pi Webcam" > /sys/kernel/config/usb_gadget/pi4/configs/c.2/strings/0x409/configuration

mkdir /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0
mkdir /sys/kernel/config/usb_gadget/pi4/functions/acm.usb0
mkdir -p /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/control/header/h
ln -s /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/control/header/h /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/control/class/fs

mkdir -p /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/dwFrameInterval
333333
EOF
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/wWidth
1920
EOF
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/wHeight
1080
EOF
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/dwMinBitRate
10000000
EOF
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/dwMaxBitRate
100000000
EOF
cat <<EOF > /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m/1080p/dwMaxVideoFrameBufferSize
7372800
EOF


mkdir /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/header/h
ln -s /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/mjpeg/m /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/header/h
ln -s /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/header/h /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/class/fs
ln -s /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/header/h /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0/streaming/class/hs

ln -s /sys/kernel/config/usb_gadget/pi4/functions/uvc.usb0 /sys/kernel/config/usb_gadget/pi4/configs/c.2/uvc.usb0
ln -s /sys/kernel/config/usb_gadget/pi4/functions/acm.usb0 /sys/kernel/config/usb_gadget/pi4/configs/c.2/acm.usb0

udevadm settle -t 5 || :
ls /sys/class/udc > /sys/kernel/config/usb_gadget/pi4/UDC

