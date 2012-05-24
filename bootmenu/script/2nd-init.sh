#!/system/bootmenu/binary/busybox ash
######## BootMenu Script
######## Execute [2nd-init] Menu

source /system/bootmenu/script/_config.sh

######## Main Script

mount -o remount,rw /
rm -f /*.rc
rm -f /*.sh
rm -f /osh
rm -rf /preinstall
cp -f /system/bootmenu/2nd-init/* /
ln -s /init /sbin/ueventd
killall ueventd

ADBD_RUNNING=`ps | grep adbd | grep -v grep`
if [ -z "$ADB_RUNNING" ]; then
    rm -f /tmp/usbd_current_state
fi

# original /tmp data symlink
if [ -L /tmp.bak ]; then
  rm /tmp.bak
fi

if [ -L /sdcard-ext ]; then
    rm /sdcard-ext
    mkdir -p /sd-ext
fi

## unmount devices
sync
umount /acct
umount /dev/cpuctl
umount /dev/pts
umount /mnt/asec
umount /mnt/obb
umount /cache
umount /data

######## Cleanup

rm -f /sbin/adbd.root
rm -f /sbin/lsof

## busybox cleanup..
for cmd in $(/sbin/busybox --list); do
    [ -L "/sbin/$cmd" ] && rm "/sbin/$cmd"
done

rm -f /sbin/busybox

## used for adbd shell (can be bash also)
/system/xbin/ln -s /system/xbin/busybox /sbin/sh

## reduce lcd backlight to save battery
echo 18 > /sys/class/leds/lcd-backlight/brightness

######## Let's go

/system/bootmenu/binary/2nd-init

