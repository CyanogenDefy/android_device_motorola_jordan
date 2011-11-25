#!/sbin/sh

######## BootMenu Script
######## Execute [ADB Daemon] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

mkdir -p /tmp
chown system.shell /tmp
chmod 0777 /tmp

# acm to disable MSC
sync
echo acm > /dev/usb_device_mode
sleep 1

# load overclock settings to reduce heat and battery use
/system/bootmenu/script/overclock.sh

echo charge_adb > /dev/usb_device_mode
echo usb_mode_charge_adb > /tmp/usbd_current_state

# busybox ash history
export HISTFILE=/tmp/.ash_history
export HISTFILESIZE=256

PATH=/sbin:/system/xbin:/system/bin /sbin/adbd.root &

exit
