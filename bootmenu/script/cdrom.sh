#!/sbin/sh

######## BootMenu Script
######## Execute [CDROM Drivers] Tool

source /system/bootmenu/script/_config.sh

######## Main Script

PARTITION=/dev/block/mmcblk1p17

# acm to disable MSC
sync
echo acm > /dev/usb_device_mode
sleep 1

echo $PARTITION > $BOARD_UMS_LUNFILE

echo cdrom > /dev/usb_device_mode
echo usb_mode_msc > /tmp/usbd_current_state

echo $PARTITION > $BOARD_UMS_LUNFILE

exit
