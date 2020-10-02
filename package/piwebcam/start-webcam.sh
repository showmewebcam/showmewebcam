#!/bin/sh

/opt/uvc-webcam/multi-gadget.sh
/usr/bin/v4l2-ctl -c auto_exposure_bias=3
/usr/bin/v4l2-ctl -c video_bitrate=25000000

CONFIG_FILE="/boot/camera.txt"
if [ -f "$CONFIG_FILE" ] ; then
  cat "$CONFIG_FILE" | grep -vE "^\#" | while read line
  do
    KEY=$(echo "$line" | cut -d= -f1)
    VAL=$(echo "$line" | cut -d= -f2)
    logger -t "piwebcam" "Setting $KEY -> $VAL"
    /usr/bin/v4l2-ctl -c "$KEY"="$VAL"
  done
fi

/opt/uvc-webcam/uvc-gadget -f1 -s1 -r1  -u /dev/video1 -v /dev/video0
