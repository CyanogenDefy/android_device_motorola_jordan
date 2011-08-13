#!/sbin/sh

######## BootMenu Script
######## Execute [CDROM Drivers] Tool


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script

BOARD_UMS_LUNFILE=/sys/devices/platform/usb_mass_storage/lun0/file
PARTITION=/dev/block/mmcblk1p17

echo $PARTITION > $BOARD_UMS_LUNFILE

echo 'cdrom' > /dev/usb_device_mode

exit
