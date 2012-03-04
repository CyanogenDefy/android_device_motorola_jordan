#!/sbin/busybox ash

if [ ! -x /system/bin/bootmenu ]; then
    mount /system
fi

if [ ! -f /cache/recovery/bootmode.conf ]; then
    mount /cache
fi

if [ -f /system/bin/bootmenu ]; then

    if [ -L /sbin/busybox ]; then
        rm /sbin/busybox
        # replace recovery symlink by full static busybox bootmenu version
        /system/bootmenu/binary/busybox cp /system/bootmenu/binary/busybox /sbin/busybox

        # keep recovery binary, for extra tools
        # rm /sbin/recovery
    fi

    echo bootmenu > /cache/recovery/bootmode.conf
    /system/bin/logwrapper /system/bin/bootmenu

    # only for real recovery.img service
    # /system/bin/toolbox stop recovery

    exit 0
fi

# fast button warning
echo 1 > /sys/class/leds/red/brightness
usleep 50000
echo 0 > /sys/class/leds/red/brightness
usleep 50000
echo 1 > /sys/class/leds/red/brightness
usleep 50000
echo 0 > /sys/class/leds/red/brightness

