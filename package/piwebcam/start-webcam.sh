#!/bin/sh


CONFIG_FILE="/boot/camera.txt"
WEB_CONFIG_FILE="/boot/picam_web.txt"
LOGGER_TAG="piwebcam"

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

os=""
ip_addr=""
if [ -f "$WEB_CONFIG_FILE" ] ; then
  logger -t "$LOGGER_TAG" "Found $WEB_CONFIG_FILE, starting WebUI"
  cat "$CONFIG_FILE" | sed "s/ //g" | grep "\S" | grep -vE "^\#" | while read -r line
  do
    KEY=$(echo "$line" | cut -d= -f1)
    VAL=$(echo "$line" | cut -d= -f2)
    logger -t "$LOGGER_TAG" "Setting $KEY -> $VAL"
    case $KEY in
      OS)
        os=$VAL
        ;;
      IP)
        ip=$VAL
        ;;
      *)
        ;;
    esac
  done

  # Configure gadgets UVC/ACM ECM/RNDIS
  if [ $os != "" ] ; then
    /opt/uvc-webcam/multi-gadget.sh $os
  else
    /opt/uvc-webcam/multi-gadget.sh linux
  fi

  # Start web server
  if [ $ip_addr != "" ] ; then
    /opt/picam-web/picam-web.sh $ip_addr
  else
    /opt/picam-web/picam-web.sh "10.0.0.1"
  fi

else
  logger -t "$LOGGER_TAG" "No $WEB_CONFIG_FILE found, start normally"
  /opt/uvc-webcam/multi-gadget.sh
  /opt/uvc-webcam/uvc-gadget -l -p 21 -b 3 -u /dev/video1 -v /dev/video0
fi
