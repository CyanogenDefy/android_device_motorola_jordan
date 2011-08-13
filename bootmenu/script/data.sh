#!/sbin/sh

######## BootMenu Script
######## Execute [USB Data Partiion] Tool


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

# acm to disable MSC
echo 'acm' > /dev/usb_device_mode
sleep 1

BOARD_UMS_LUNFILE=/sys/devices/platform/usb_mass_storage/lun0/file
PARTITION=/dev/block/mmcblk1p25

echo $PARTITION > $BOARD_UMS_LUNFILE

# charge_only support MSC
echo 'charge_only' > /dev/usb_device_mode

exit
