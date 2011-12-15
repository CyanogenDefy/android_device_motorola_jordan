#!/system/bin/sh
#
# Used in Android before reboot, and in all "reboot" shell commands

BM_CONFIG=/cache/recovery/bootmode.conf

R=$1
if [ -n "$2" ]; then
  R=$2
fi

if [ "$R" = "recovery" ]; then

  echo "recovery" > $BM_CONFIG

fi

if [ "$R" = "bootloader" ]; then

  echo "bootmenu" > $BM_CONFIG

fi

if [ "$R" = "bootmenu" ]; then

  echo "bootmenu" > $BM_CONFIG

fi

if [ "$R" = "shell" ]; then

  echo "shell" > $BM_CONFIG

fi

if [ -z "$R" ]; then
  rm -f $BM_CONFIG
fi

sync
