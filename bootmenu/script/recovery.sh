#!/sbin/sh

######## BootMenu Script
######## Execute [Latest Recovery] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

## /tmp folder can be a link to /data/tmp, bad thing !
[ -L /tmp ] && rm /tmp
mkdir -p /tmp
mkdir -p /res

rm -f /etc
mkdir /etc

# hijack mke2fs & tune2fs CWM3
rm -f /sbin/mke2fs
rm -f /sbin/tune2fs
rm -f /sbin/e2fsck

rm -f /sdcard
mkdir /sdcard

chmod 755 /sbin
chmod 755 /res

cp -r -f /system/bootmenu/recovery/res/* /res/
cp -p -f /system/bootmenu/recovery/sbin/* /sbin/
cp -p -f /system/bootmenu/script/recoveryexit.sh /sbin/

if [ ! -f /sbin/recovery ]; then
    ln -s /sbin/recovery_stable /sbin/recovery
fi

chmod +rx /sbin/*

rm -f /sbin/postrecoveryboot.sh

if [ ! -e /etc/recovery.fstab ]; then
    cp /system/bootmenu/recovery/recovery.fstab /etc/recovery.fstab
fi

mkdir -p /cache/recovery
touch /cache/recovery/command
touch /cache/recovery/log
touch /cache/recovery/last_log
touch /tmp/recovery.log

killall adbd

# load overclock settings to reduce heat and battery use
/system/bootmenu/script/overclock.sh

# mount image of pds, for backup purpose (4MB)
dd if=/dev/block/mmcblk1p7 of=/tmp/pds.img bs=4096
if [ -f /tmp/pds.img ] ; then
    mkdir -p /pds
    umount /pds 2>/dev/null
    losetup /dev/block/loop7 /tmp/pds.img
    busybox mount -o rw,nosuid,nodev,noatime,nodiratime,barrier=1 /dev/block/loop7 /pds
fi

ps | grep -v grep | grep adbd
ret=$?

if [ ! $ret -eq 0 ]; then
   # chmod 755 /system/bootmenu/script/adbd.sh
   # /system/bootmenu/script/adbd.sh

   # don't use adbd here, will load many android process which locks /system
   killall adbd
   killall adbd.root
fi

#############################
# mount in /sbin/postrecoveryboot.sh
umount /system

usleep 50000
mount -t ext3 -o rw,noatime,nodiratime /dev/block/mmcblk1p21 /system

# retry without type & options if not mounted
[ ! -f /system/build.prop ] && mount -o rw /dev/block/mmcblk1p21 /system

# set red led if problem with system

echo 0 > /sys/class/leds/red/brightness
echo 0 > /sys/class/leds/green/brightness
echo 0 > /sys/class/leds/blue/brightness
[ ! -f /system/build.prop ] && echo 1 > /sys/class/leds/red/brightness

#############################

# turn on button backlight (back button is used in CWM Recovery 3.x)
echo 1 > /sys/class/leds/button-backlight/brightness


/sbin/recovery


# Post Recovery (back to bootmenu)

# bootmenu doesnt support buttons
echo 0 > /sys/class/leds/button-backlight/brightness

# remount system & data if unmounted
[ ! -d /data/data ] &&         mount -t ext3 -o rw,noatime,nodiratime,errors=continue /dev/block/mmcblk1p25 /data
[ ! -f /system/build.prop ] && mount -t ext3 -o rw,noatime,nodiratime,errors=continue /dev/block/mmcblk1p21 /system

if [ -f /system/build.prop ] ; then
	echo 0 > /sys/class/leds/red/brightness
	echo 0 > /sys/class/leds/green/brightness
	echo 1 > /sys/class/leds/blue/brightness
else
	echo 1 > /sys/class/leds/red/brightness
	echo 0 > /sys/class/leds/green/brightness
	echo 0 > /sys/class/leds/blue/brightness
fi


exit
