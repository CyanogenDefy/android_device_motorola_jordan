#!/system/bin/sh

# fast button warning
echo 1 > /sys/class/leds/red/brightness
usleep 50000
echo 0 > /sys/class/leds/red/brightness
usleep 50000
echo 1 > /sys/class/leds/red/brightness
usleep 50000
echo 0 > /sys/class/leds/red/brightness

