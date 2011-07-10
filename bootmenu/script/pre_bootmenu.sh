#!/system/bin/sh

######## BootMenu Script
######## Execute Pre BootMenu


export PATH=/sbin:/system/xbin:/system/bin


######## Main Script

mount -o remount,rw rootfs /

BB="/sbin/busybox"

# RECOVERY tool includes busybox
cp -f /system/bootmenu/recovery/sbin/recovery $BB

# add lsof to debug locks
cp -f /system/bootmenu/binary/lsof /sbin/lsof

chmod 755 /sbin
chmod 755 $BB
$BB chown 0.0 $BB
$BB chmod 4755 $BB
$BB chmod +rx /sbin/*

# busybox sym link..
for cmd in $($BB --list); do
  $BB ln -s /sbin/busybox /sbin/$cmd
done

$BB chmod -R +x /sbin

# replace /sbin/adbd..
cp -f /system/bootmenu/binary/adbd /sbin/adbd.root
$BB chmod 4755 /sbin/adbd.root
$BB chown 0.0 /sbin/adbd.root

## missing system files
[ ! -c /dev/tty0 ]  && ln -s /dev/tty /dev/tty0

## /default.prop replace..
rm -f /default.prop
cp -f /system/bootmenu/config/default.prop /default.prop

## reduce lcd backlight to save battery
echo 44 > /sys/class/leds/lcd-backlight/brightness

exit
