#!/system/bin/sh

######## BootMenu Script
######## Execute Pre BootMenu

export PATH=/sbin:/system/xbin:/system/bin

PART_CACHE=/dev/block/mmcblk1p24

######## Main Script


BB_STATIC="/system/bootmenu/binary/busybox"

BB="/sbin/busybox"

## reduce lcd backlight to save battery
echo 64 > /sys/class/leds/lcd-backlight/brightness


# these first commands are duplicated for broken systems
mount -o remount,rw rootfs /
$BB_STATIC mount -o remount,rw /

# we will use the static busybox
cp -f $BB_STATIC $BB
$BB_STATIC cp -f $BB_STATIC $BB

chmod 755 /sbin
chmod 755 $BB
$BB chown 0.0 $BB
$BB chmod 4755 $BB

if [ -f /sbin/chmod ]; then
    # job already done...
    exit 0
fi

# busybox sym link..
for cmd in $($BB --list); do
    $BB ln -s /sbin/busybox /sbin/$cmd
done

# add lsof to debug locks
cp -f /system/bootmenu/binary/lsof /sbin/lsof

$BB chmod +rx /sbin/*

# custom adbd (allow always root)
cp -f /system/bootmenu/binary/adbd /sbin/adbd.root
chown 0.0 /sbin/adbd.root
chmod 4755 /sbin/adbd.root

# opensource adbd
cp -f /system/bin/adbd /sbin/adbd
chown 0.0  /sbin/adbd
chmod 4750 /sbin/adbd

## missing system files
[ ! -c /dev/tty0 ]  && ln -s /dev/tty /dev/tty0

## /default.prop replace.. (TODO: check if that works)
rm -f /default.prop
cp -f /system/bootmenu/config/default.prop /default.prop

## mount cache
mkdir -p /cache

# stock mount, with fsck
if [ -x /system/bin/mount_ext3.sh ]; then
    /system/bin/mount_ext3.sh cache /cache
fi

# mount cache for boot mode and recovery logs
if [ ! -d /cache/recovery ]; then
    mount -t ext3 -o nosuid,nodev,noatime,nodiratime,barrier=1 $PART_CACHE /cache
fi

mkdir -p /cache/bootmenu

# load ondemand safe settings to reduce heat and battery use
if [ -x /system/bootmenu/script/overclock.sh ]; then
    /system/bootmenu/script/overclock.sh safe
fi

exit 0
