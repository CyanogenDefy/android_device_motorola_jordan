#!/sbin/sh

PATH=$PATH:/sbin:/system/xbin:/system/bin

if [ -x /system/bin/mount_ext3.sh ]; then
    mount_ext3.sh cache /cache
else
    mount -t ext3 -o nosuid,nodev,noatime,nodiratime,barrier=1 /dev/block/cache /cache
fi

mv /cache/recovery/bootmode.conf /cache/recovery/last_bootmode

