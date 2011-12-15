#!/sbin/sh

######## BootMenu Script
######## Execute [USB /system Partition] Tool

source /system/bootmenu/script/_config.sh

######## Main Script

# acm to disable MSC
sync
echo acm > /dev/usb_device_mode
sleep 1

PARTITION=$PART_SYSTEM

echo $PARTITION > $BOARD_UMS_LUNFILE

# charge_only support MSC
echo charge_only > /dev/usb_device_mode
echo usb_mode_charge > /tmp/usbd_current_state

echo $PARTITION > $BOARD_UMS_LUNFILE

exit
