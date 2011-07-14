#!/system/bin/sh
#
# Used in Android before reboot, and in all "reboot" shell commands

if [ "$1" = "recovery" ]; then

  echo 1 > /sys/class/leds/blue/brightness
  echo "recovery" > /cache/recovery/bootmode.conf
  sync
  echo 0 > /sys/class/leds/blue/brightness

fi

if [ -z "$1" ]; then
  rm /cache/recovery/bootmode.conf
fi

