#!/system/bin/sh

######## BootMenu Script
######## Execute Pre BootMenu


export PATH=/sbin:/system/xbin:/system/bin


######## Main Script

mount -o remount,rw rootfs /

BB="/sbin/busybox"

# RECOVERY tool includes busybox
cp -f /system/bootmenu/recovery/sbin/recovery $BB
cp -f /system/bootmenu/recovery/sbin/recovery_stable $BB

# add lsof to debug locks
cp -f /system/bootmenu/binary/lsof /sbin/lsof

chmod 755 /sbin
chmod 755 $BB
$BB chown 0.0 $BB
$BB chmod 4755 $BB
$BB chmod +rx /sbin/*

if [ -f /sbin/chmod ]; then
  # job already done...
  exit 0
fi

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
echo 64 > /sys/class/leds/lcd-backlight/brightness

## mount cache
mkdir -p /cache

if [ -x /system/bin/mount_ext3.sh ]; then
  /system/bin/mount_ext3.sh cache /cache
else
  mount -t ext3 -o nosuid,nodev,noatime,nodiratime,barrier=1 /dev/block/mmcblk1p24 /cache
fi

exit 0
