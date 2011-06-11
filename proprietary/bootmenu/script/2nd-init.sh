#!/sbin/sh

######## BootMenu Script
######## Execute [2nd-init] Menu


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script


echo 1 > /sys/class/leds/green/brightness
usleep 500000
echo 0 > /sys/class/leds/green/brightness


rm /*.rc
cp -r -f /system/bootmenu/2nd-init/* /
chmod 755 /*.rc
chmod 755 /system/bootmenu/binary/2nd-init


umount /acct
umount /mnt/asec
umount /dev/cpuctl
umount /dev/pts
umount /mnt/obb


# Cleanup

rm /sbin/lsof
#rm /sbin/adbd.root

## busybox cleanup..
for cmd in $(/sbin/busybox --list); do
  [ -L "/sbin/$cmd" ] && rm "/sbin/$cmd"
done

rm /sbin/busybox

rm -f /rootsh

ln -s /system/xbin/busybox /sbin/modprobe

/system/bootmenu/binary/2nd-init

exit
