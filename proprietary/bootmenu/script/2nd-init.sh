#!/sbin/sh

######## BootMenu Script v0.6.1
######## Execute [2nd-init] Menu


export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary

######## Main Script

rm /*.rc
cp -r -f /system/bootmenu/2nd-init/* /
chmod 755 /*.rc

######## Fix me..
#### killall -9 adbd.root # To developer..
########

umount /acct
umount /mnt/asec
umount /dev/cpuctl
umount /dev/pts

chmod 755 /system/bootmenu/binary/2nd-init
/system/bootmenu/binary/2nd-init

exit
