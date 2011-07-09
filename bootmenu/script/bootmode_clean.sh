#!/sbin/sh

busybox mount -o remount,rw /system

rm /system/bootmenu/config/bootmode.conf

