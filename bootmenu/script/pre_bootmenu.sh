#!/system/bootmenu/binary/busybox ash

######## BootMenu Script
######## Execute Pre BootMenu

source /system/bootmenu/script/_config.sh

######## Main Script


BB_STATIC=$BM_ROOTDIR/binary/busybox

BB=/sbin/busybox

## reduce lcd backlight to save battery
echo 64 > /sys/class/leds/lcd-backlight/brightness


$BB_STATIC mount -o remount,rw /

# we will use the static busybox
$BB_STATIC cp -f $BB_STATIC /sbin/

$BB_STATIC chmod 755 /sbin
$BB_STATIC chown 0.0 $BB
$BB_STATIC chmod 4755 $BB

if [ -f /sbin/chmod ]; then
    # job already done...
    exit 0
fi

# busybox sym link..
for cmd in $($BB --list); do
    $BB ln -s $BB /sbin/$cmd
done

rm -f /sbin/reboot

# add lsof to debug locks
cp -f $BM_ROOTDIR/binary/lsof /sbin/lsof

chmod +rx /sbin/*

# backup original init.rc
if [ ! -f $BM_ROOTDIR/moto/init.rc ]; then
    mkdir -p $BM_ROOTDIR/moto
    cp /*.rc $BM_ROOTDIR/moto/
fi

# custom adbd (allow always root)
cp -f $BM_ROOTDIR/binary/adbd.root /sbin/adbd.root
chown 0.0 /sbin/adbd.root
chmod 4755 /sbin/adbd.root

## missing system files
[ ! -c /dev/tty0 ]  && ln -s /dev/tty /dev/tty0

## /default.prop replace.. (TODO: check if that works)
rm -f /default.prop
cp -f $BM_ROOTDIR/config/default.prop /default.prop

## mount cache
mkdir -p /cache

# stock mount, with fsck
if [ -x /system/bin/mount_ext3.sh ]; then
    /system/bin/mount_ext3.sh cache /cache
fi

# mount cache for boot mode and recovery logs
if [ ! -d /cache/recovery ]; then
    mount -t $FS_CACHE -o nosuid,nodev,noatime,nodiratime,barrier=1 $PART_CACHE /cache
fi

mkdir -p /cache/bootmenu

# load ondemand safe settings to reduce heat and battery use
if [ -x $BM_ROOTDIR/script/overclock.sh ]; then
    $BM_ROOTDIR/script/overclock.sh safe
fi

# must be restored in stock.sh
if [ -L /tmp ]; then
  mv /tmp /tmp.bak
  mkdir /tmp && busybox mount -t ramfs ramfs /tmp
fi

exit 0
