#!/system/bin/sh

######## BootMenu Script
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

if [ -d /system/bootmenu/init.d ]; then
    chmod 755 /system/bootmenu/init.d/*
    run-parts /system/bootmenu/init.d/
fi

chmod 755 /system/etc/init.d/*
run-parts /system/etc/init.d/

# normal cleanup here (need fix in recovery first)
# ...


# fast button warning (to check when script is really used)
if [ -f /sbin/busybox ]; then

echo 1 > /sys/class/leds/button-backlight/brightness
usleep 50000
echo 0 > /sys/class/leds/button-backlight/brightness
usleep 50000
echo 1 > /sys/class/leds/button-backlight/brightness
usleep 50000
echo 0 > /sys/class/leds/button-backlight/brightness
usleep 50000
echo 1 > /sys/class/leds/button-backlight/brightness
usleep 50000
echo 0 > /sys/class/leds/button-backlight/brightness

exit 1

fi

######## Don't Delete.... ########################
mount -o remount,ro rootfs /
mount -o remount,ro /dev/block/mmcblk1p21 /system
##################################################

# /system/bootmenu/script/media_fixup.sh &

exit 0
