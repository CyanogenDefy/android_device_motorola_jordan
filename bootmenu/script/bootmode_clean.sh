#!/sbin/sh

mount_ext3.sh cache /cache

rm /cache/recovery/bootmode.conf

# busybox mount -o remount,rw /system
# rm /system/bootmenu/config/bootmode.conf

