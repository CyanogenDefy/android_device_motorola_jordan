#!/sbin/sh

######## BootMenu Script
######## Execute [USB Data Partition] Tool


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

# acm to disable MSC
sync
echo acm > /dev/usb_device_mode
sleep 1

BOARD_UMS_LUNFILE=/sys/devices/platform/usb_mass_storage/lun0/file
PARTITION=/dev/block/mmcblk1p25

echo $PARTITION > $BOARD_UMS_LUNFILE

# charge_only support MSC
echo charge_only > /dev/usb_device_mode
echo usb_mode_charge > /tmp/usbd_current_state

echo $PARTITION > $BOARD_UMS_LUNFILE

exit
