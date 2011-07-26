#!/system/bin/sh
#
# Used in Android before reboot, and in all "reboot" shell commands

if [ "$1" = "recovery" ]; then

  echo "recovery" > /cache/recovery/bootmode.conf

fi

if [ "$1" = "bootloader" ]; then

  echo "bootmenu" > /cache/recovery/bootmode.conf

fi

if [ "$1" = "bootmenu" ]; then

  echo "bootmenu" > /cache/recovery/bootmode.conf

fi

if [ -z "$1" ]; then
  rm /cache/recovery/bootmode.conf
fi

sync
