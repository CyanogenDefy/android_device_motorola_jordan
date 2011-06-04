#!/sbin/sh

######## BootMenu Script v0.8.6
######## Execute Post BootMenu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

# there is a problem, this script is executed if we 
# exit from recovery...

echo 0 > /sys/class/leds/blue/brightness

## Run Init Script

######## Don't Delete.... ########################
mount -o remount,rw rootfs /
mount -o remount,rw /dev/block/mmcblk1p21 /system
##################################################

chmod 755 /system/bootmenu/init.d/*
run-parts /system/bootmenu/init.d/

# normal cleanup here (need fix in recovery first)
# ...

######## Don't Delete.... ########################
mount -o remount,ro rootfs /
mount -o remount,ro /dev/block/mmcblk1p21 /system
##################################################

exit
