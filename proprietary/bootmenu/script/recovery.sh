#!/sbin/sh

######## BootMenu Script v0.6.1
######## Execute [Custom Recovery] Menu


export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary

######## Main Script

mkdir /tmp
mkdir /cache
mkdir /pds
mkdir /res

rm -f /sdcard
mkdir /sdcard

chmod 755 /sbin
chmod 755 /res

cp -r -f /system/bootmenu/recovery/res/* /res/
cp -r -f /system/bootmenu/recovery/sbin/* /sbin/

chmod 755 /sbin/*

rm -f /sbin/postrecoveryboot.sh

/sbin/recovery

exit
