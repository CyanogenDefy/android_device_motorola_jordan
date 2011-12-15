#!/sbin/sh

######## BootMenu Script
######## Execute [Mass Storage] Tool

source /system/bootmenu/script/_config.sh

######## Main Script

# acm to reset msc
sync
echo acm > /dev/usb_device_mode
umount /sdcard
sleep 1

PARTITION=/dev/block/mmcblk0

echo $PARTITION > $BOARD_UMS_LUNFILE

# charge_only support MSC
echo charge_only > /dev/usb_device_mode
echo usb_mode_charge > /tmp/usbd_current_state

echo $PARTITION > $BOARD_UMS_LUNFILE

exit
