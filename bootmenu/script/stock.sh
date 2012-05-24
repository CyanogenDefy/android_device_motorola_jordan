#!/sbin/sh

######## BootMenu Script
######## Execute [Normal] Boot (disabled in cm7)


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

busybox mount -o remount,rw /
busybox cp -f /system/bootmenu/binary/adbd /sbin/adbd
busybox chmod 4755 /sbin/adbd
busybox chown root.system /sbin/adbd

# restore original /tmp data symlink
if [ -L /tmp.bak ]; then
  busybox umount /tmp
  busybox mv /tmp.bak /tmp
fi

######## Cleanup

rm -f /sbin/lsof

## busybox applets cleanup..
for cmd in $(/sbin/busybox --list); do
  [ -L "/sbin/$cmd" ] && [ "$cmd" != "sh" ] && rm "/sbin/$cmd"
done

#rm /sbin/busybox

## reduce lcd backlight to save battery
echo 18 > /sys/class/leds/lcd-backlight/brightness

