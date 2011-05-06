#!/sbin/sh

######## BootMenu Script v0.6.1
######## Execute Post BootMenu


export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary

######## Main Script

#### kill adbd

######## Fix me..
killall -9 adbd
killall -9 adbd.root

##kill -9 $(/sbin/ps |
##grep 'adbd' |
##grep -v 'grep' |
##cut -d ' ' -f2)
########


######## Don't Delete.... ############
mount -o remount,ro rootfs /
######################################

exit
