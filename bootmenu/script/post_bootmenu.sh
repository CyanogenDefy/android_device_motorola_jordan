#!/system/bin/sh

######## BootMenu Script
######## Execute Post BootMenu

source /system/bootmenu/script/_config.sh

export PATH=/system/xbin:/system/bin:/sbin

######## Main Script

# there is a problem, this script is executed if we 
# exit from recovery...

echo 0 > /sys/class/leds/blue/brightness

## Run Init Script

######## Don't Delete.... ########################
mount -o remount,rw rootfs /
mount -o remount,rw $PART_SYSTEM /system
##################################################

if [ -d /system/bootmenu/init.d ]; then
    chmod 755 /system/bootmenu/init.d/*
    run-parts /system/bootmenu/init.d/
fi

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
mount -o remount,ro $PART_SYSTEM /system
##################################################

# /system/bootmenu/script/media_fixup.sh &

exit 0
