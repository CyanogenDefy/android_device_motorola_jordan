#!/system/bin/sh
#
# Used in Android before reboot, and in all "reboot" shell commands

R=$1
if [ -n "$2" ]; then
  R=$2
fi

if [ "$R" = "recovery" ]; then

  echo "recovery" > /cache/recovery/bootmode.conf

fi

if [ "$R" = "bootloader" ]; then

  echo "bootmenu" > /cache/recovery/bootmode.conf

fi

if [ "$R" = "bootmenu" ]; then

  echo "bootmenu" > /cache/recovery/bootmode.conf

fi

if [ -z "$R" ]; then
  rm /cache/recovery/bootmode.conf
fi

sync
