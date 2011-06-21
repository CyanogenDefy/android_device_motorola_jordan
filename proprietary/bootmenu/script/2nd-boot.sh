#!/sbin/sh

######## BootMenu Script
######## Execute [2nd-boot] Menu (froyo alt 2nd-init)


export PATH=/sbin:/system/xbin:/system/bin

######## Main Script


echo 1 > /sys/class/leds/red/brightness
usleep 100000
echo 0 > /sys/class/leds/red/brightness


rm /*.rc
cp -r -f /system/bootmenu/2nd-boot/* /
chmod 755 /*.rc
chmod 4755 /system/bootmenu/binary/2nd-boot


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

# ln -s /system/xbin/busybox /sbin/modprobe

/system/bootmenu/binary/2nd-boot

exit
