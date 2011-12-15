#!/sbin/sh

######## BootMenu Script
######## Execute [ADB Daemon] Menu

source /system/bootmenu/script/_config.sh

######## Main Script

mkdir -p /tmp
chown system.shell /tmp
chmod 0777 /tmp

# acm to disable MSC
sync
echo acm > /dev/usb_device_mode
sleep 1

echo charge_adb > /dev/usb_device_mode
echo usb_mode_charge_adb > /tmp/usbd_current_state

# busybox ash history
mkdir -p /cache/bootmenu
export HISTFILE=/cache/bootmenu/.ash_history
export HISTFILESIZE=256

PATH=/sbin:/system/xbin:/system/bin /sbin/adbd.root &

exit
