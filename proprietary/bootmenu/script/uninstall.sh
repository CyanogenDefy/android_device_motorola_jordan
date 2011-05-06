#!/sbin/sh

######## BootMenu Script v0.6.1
######## Execute [Uninstall BootMenu] Menu


export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary

######## Main Script

rm /system/bin/logwrapper
mv /system/bin/logwrapper.bin /system/bin/logwrapper

rm -r /system/bootmenu

exit
