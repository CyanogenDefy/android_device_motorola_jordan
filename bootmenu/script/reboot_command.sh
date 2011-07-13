#!/system/bin/sh
#
# Used in Android before reboot, and in all "reboot" shell commands

if [ "$1" = "recovery" ]; then

  echo 1 > /sys/class/leds/blue/brightness

  echo "recovery" > /cache/recovery/bootmode.conf

  # useless in this script, not written when script is executed
  # but kept for the future
  CMD=""
  if [ -f /cache/recovery/command ]; then
    cp -f /cache/recovery/command /system/bootmenu/config/command

    CMD="`cat /cache/recovery/command`"

    rm /cache/recovery/command
  fi

  # common commands
  if [ "$CMD" = "--wipe_data" ]; then

    # todo...
    echo 1 > /sys/class/leds/red/brightness

  fi

  # --update_package=filename
  if [ -n "`echo $CMD | grep update_package`" ]; then

    # todo...
    echo 1 > /sys/class/leds/green/brightness
  fi


  sync

  echo 0 > /sys/class/leds/blue/brightness

fi

if [ -z "$1" ]; then
  rm /cache/recovery/bootmode.conf
fi

