#!/sbin/sh

######## BootMenu Script v0.6.1
######## Execute [ADB Daemon] Menu


export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary

######## Main Script

######## Fix me..
#### killall adbd
#### killall adbd.root
########

mkdir /tmp
echo 'msc_adb' > /dev/usb_device_mode

PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary /sbin/adbd.root &

exit
