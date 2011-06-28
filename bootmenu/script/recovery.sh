#!/sbin/sh

######## BootMenu Script
######## Execute [Custom Recovery] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

# Moto 2.3.3 /tmp is a link to /data/tmp, bad thing !
[ -L /tmp ] && rm /tmp

mkdir /tmp
mkdir /cache
mkdir /pds
mkdir /res

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

chmod +rx /sbin/*

rm -f /sbin/postrecoveryboot.sh

if [ ! -e /etc/recovery.fstab ]; then
  cp /system/bootmenu/recovery/recovery.fstab /etc/recovery.fstab
fi

if [ -x /system/bin/mount_ext3.sh ]; then
  /system/bin/mount_ext3.sh cache /cache
else
  mount -t ext3 -o nosuid,nodev,noatime,nodiratime,barrier=1 /dev/block/cache /cache
fi

mkdir /cache/recovery
touch /cache/recovery/command
touch /cache/recovery/log
touch /cache/recovery/last_log
touch /tmp/recovery.log

killall adbd
sleep 1
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

# set red led if problem with system, green led else

echo 0 > /sys/class/leds/red/brightness
echo 0 > /sys/class/leds/green/brightness
echo 0 > /sys/class/leds/blue/brightness
[ ! -f /system/build.prop ] && echo 1 > /sys/class/leds/red/brightness
# [ -f /system/build.prop ] && echo 1 > /sys/class/leds/green/brightness

#############################

# turn on button backlight (back button is used in CWM Recovery 3.x)
echo 1 > /sys/class/leds/button-backlight/brightness


/sbin/recovery


# Post Recovery (back to bootmenu)

# bootmenu doesnt support buttons
echo 0 > /sys/class/leds/button-backlight/brightness

# remount system & data if unmounted
[ ! -d /data/data ] &&         mount -t ext3 -o rw,noatime,nodiratime,errors=continue /dev/block/userdata /data
[ ! -f /system/build.prop ] && mount -t ext3 -o rw,noatime,nodiratime,errors=continue /dev/block/system /system

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
