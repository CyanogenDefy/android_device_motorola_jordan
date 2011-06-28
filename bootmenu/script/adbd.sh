#!/sbin/sh

######## BootMenu Script
######## Execute [ADB Daemon] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

mkdir /tmp
echo 'msc_adb' > /dev/usb_device_mode

PATH=/sbin:/system/xbin:/system/bin /sbin/adbd.root &

exit
