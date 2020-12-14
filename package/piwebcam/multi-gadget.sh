#!/bin/sh
#
# Thank to 
#   wismna: http://github.com/wismna/raspberry-pi/hackpi
#   RoganDawes: https://github.com/RoganDawes/P4wnP1

# https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/enumeration-of-the-composite-parent-device
# https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-common-class-generic-parent-driver

OS_CONFIG="$1"
MAC_HOST="48:6f:73:74:50:43" # "Mac address for host PC"
MAC_SELF="42:61:64:55:53:42" # "MAC address for PiCam"
CONFIG=/sys/kernel/config/usb_gadget/piwebcam

mkdir -p "$CONFIG"
cd "$CONFIG" || exit 1


# 0x04b3 = 1203
# {
#     "name": "IBM Corporation",
#     "field_vid": "1203"
# },
OS_CONFIG=$(echo $OS_CONFIG | tr '[A-Z]' '[a-z]')
case $OS_CONFIG in
  window)
    # wismna hack for Window
    # IBM Corporation RNDIS Driver will be loaded
    echo 0x04b3 > idVendor
    echo 0x4010 > idProduct
    ;;
  *)
    echo 0x1d6b > idVendor   # Linux Foundation
    echo 0x0104 > idProduct  # Multifunction Composite Gadget
    ;;

esac

echo 0x0100 > bcdDevice
echo 0x0200 > bcdUSB

# Mandatory for Multiple Gadgets 
echo 0xEF > bDeviceClass
echo 0x02 > bDeviceSubClass
echo 0x01 > bDeviceProtocol
echo 0x40 > bMaxPacketSize0

mkdir -p strings/0x409
mkdir -p configs/c.1/strings/0x409
echo 100000000d2386db         > strings/0x409/serialnumber
echo "Show-me Webcam Project" > strings/0x409/manufacturer
echo "Piwebcam "              > strings/0x409/product
echo 250                      > configs/c.1/MaxPower
echo "Piwebcam"               > configs/c.1/strings/0x409/configuration



config_frame () {
  FORMAT=$1
  NAME=$2
  WIDTH=$3
  HEIGHT=$4

  FRAMEDIR="functions/uvc.usb0/streaming/$FORMAT/$NAME/${HEIGHT}p"

  mkdir -p "$FRAMEDIR"

  echo "$WIDTH"                    > "$FRAMEDIR"/wWidth
  echo "$HEIGHT"                   > "$FRAMEDIR"/wHeight
  echo 333333                      > "$FRAMEDIR"/dwDefaultFrameInterval
  echo $(($WIDTH * $HEIGHT * 80))  > "$FRAMEDIR"/dwMinBitRate
  echo $(($WIDTH * $HEIGHT * 160)) > "$FRAMEDIR"/dwMaxBitRate
  echo $(($WIDTH * $HEIGHT * 2))   > "$FRAMEDIR"/dwMaxVideoFrameBufferSize
  cat <<EOF > "$FRAMEDIR"/dwFrameInterval
333333
400000
666666
EOF
}

config_uvc () {
  mkdir -p functions/uvc.usb0/control/header/h

  config_frame mjpeg m  640  360
  config_frame mjpeg m  640  480
  config_frame mjpeg m  800  600
  config_frame mjpeg m 1024  768
  config_frame mjpeg m 1280  720
  config_frame mjpeg m 1280  960
  config_frame mjpeg m 1440 1080
  config_frame mjpeg m 1536  864
  config_frame mjpeg m 1600  900
  config_frame mjpeg m 1600 1200
  config_frame mjpeg m 1920 1080

  mkdir -p functions/uvc.usb0/streaming/header/h
  ln -s functions/uvc.usb0/streaming/mjpeg/m  functions/uvc.usb0/streaming/header/h
  ln -s functions/uvc.usb0/streaming/header/h functions/uvc.usb0/streaming/class/fs
  ln -s functions/uvc.usb0/streaming/header/h functions/uvc.usb0/streaming/class/hs
  ln -s functions/uvc.usb0/control/header/h   functions/uvc.usb0/control/class/fs

  ln -s functions/uvc.usb0 configs/c.1/uvc.usb0
}

config_acm(){
  mkdir -p functions/acm.usb0
  ln -s functions/acm.usb0 configs/c.1/acm.usb0
}

# Ethernet Adapter
#-------------------------------------------
config_rndis () {
  mkdir -p functions/rndis.usb0
  echo $MAC_HOST > functions/rndis.usb0/host_addr
  echo $MAC_SELF > functions/rndis.usb0/dev_addr

  mkdir -p os_desc
  echo "0x80"     > configs/c.1/bmAttributes
  echo "1"        > os_desc/use
  echo "0xbc"     > os_desc/b_vendor_code
  echo "MSFT100"  > os_desc/qw_sign

  mkdir -p functions/rndis.usb0/os_desc/interface.rndis
  echo "RNDIS"    > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
  echo "5162001"  > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id

  ln -s functions/rndis.usb0 configs/c.1/
  ln -s configs/c.1/ os_desc
}

config_ecm () {
  mkdir -p functions/ecm.usb0
  echo $MAC_HOST > functions/ecm.usb0/host_addr
  echo $MAC_SELF > functions/ecm.usb0/dev_addr
  ln -s functions/ecm.usb0 configs/c.1/
}

case $OS_CONFIG in
  window)
    config_rndis
    ;;
  macos | linux)
    config_ecm
    ;;
  *)
    config_uvc
    config_acm
    ;;
esac

udevadm settle -t 5 || :
ls /sys/class/udc > UDC
