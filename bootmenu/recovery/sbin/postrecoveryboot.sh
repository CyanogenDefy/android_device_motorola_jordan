#!/sbin/sh

sleep 5

for i in $(seq 1 10)
do
    TMP=$(mount | grep /tmp)
    if [ -z "$TMP" ]
    then
        break
    fi
    umount -l /tmp
    sleep 1
done

mount -o remount,rw rootfs /
rm -r /tmp
mkdir -p tmp
touch /tmp/recovery.log
rm sdcard
mkdir sdcard


## ???

# busybox kill $(busybox ps | busybox grep adbd)
# killall adbd
# echo msc_adb > /dev/usb_device_mode
# kill $(ps | grep /sbin/adbd)
#killall adbd

sync

# /sbin/adbd recovery &