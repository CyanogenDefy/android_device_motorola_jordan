#!/sbin/sh

######## BootMenu Script
######## Execute [Normal] Boot


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

mount -o remount,rw /
cp -f /system/bootmenu/binary/adbd /sbin/adbd
chmod 4755 /sbin/adbd
chown root.system /sbin/adbd

######## Cleanup

rm -f /sbin/lsof

## busybox cleanup..
#for cmd in $(/sbin/busybox --list); do
#  [ -L "/sbin/$cmd" ] && rm "/sbin/$cmd"
#done

#rm /sbin/busybox

## reduce lcd backlight to save battery
echo 18 > /sys/class/leds/lcd-backlight/brightness

