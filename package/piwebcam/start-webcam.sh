#!/bin/sh

CONFIG_FILE="/boot/camera.txt"
LOGGER_TAG="piwebcam"

if [ ! -e /dev/video0 ] || [ ! -e /dev/video1 ] ; then
  logger -t "$LOGGER_TAG" "One video device is missing, will not start uvc-webcam"
  exit 1
fi

if [ -f "$CONFIG_FILE" ] ; then
  logger -t "$LOGGER_TAG" "Found camera.txt, applying settings"
  #shellcheck disable=SC2002
  cat "$CONFIG_FILE" | sed "s/ //g" | grep "\S" | grep -vE "^\#" | while read -r line
  do
    KEY=$(echo "$line" | cut -d= -f1)
    VAL=$(echo "$line" | cut -d= -f2)
    logger -t "$LOGGER_TAG" "Setting $KEY -> $VAL"
    /usr/bin/v4l2-ctl -c "$KEY"="$VAL"
  done
else
  logger -t "$LOGGER_TAG" "No camera.txt found in boot"
fi

exec /opt/uvc-webcam/uvc-gadget -l -p 21 -b 3 -u /dev/video1 -v /dev/video0
