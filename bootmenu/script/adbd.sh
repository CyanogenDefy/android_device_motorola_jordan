#!/sbin/sh

######## BootMenu Script
######## Execute [ADB Daemon] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

mkdir -p /tmp

echo acm > /dev/usb_device_mode
sleep 1

echo charge_adb > /dev/usb_device_mode

# load overclock settings to reduce heat and battery use
/system/bootmenu/script/overclock.sh

PATH=/sbin:/system/xbin:/system/bin /sbin/adbd.root &

exit
