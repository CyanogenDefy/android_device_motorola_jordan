#!/system/bin/sh

export PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary


#### begin alias command ############################################

export_cmd()
{
  ALIAS=$1
  COMMAND=$2

  if [ -x /sbin/$COMMAND ]; then
    export $ALIAS="/sbin/$COMMAND"
  else if [ -x /system/xbin/$COMMAND ]; then
    export $ALIAS="/system/xbin/$COMMAND"
  else if [ -x /system/bin/$COMMAND ]; then
    export $ALIAS="/system/bin/$COMMAND"
  else if [ -x /system/xbin/busybox ]; then
    export $ALIAS="/system/xbin/busybox $COMMAND"
  else if [ -x /sbin/busybox ]; then
    export $ALIAS="/sbin/busybox $COMMAND"
  else
    export $ALIAS="/system/bin/busybox $COMMAND"
  fi; fi; fi; fi; fi
}

alias_cmd()
{
  export_cmd "BUSYBOX" "busybox"
  export_cmd "MOUNT" "mount"
  export_cmd "RM" "rm"
  export_cmd "CP" "cp"
  export_cmd "KILL" "kill"
  export_cmd "KILLALL" "killall"
  export_cmd "GREP" "grep"
  export_cmd "CHMOD" "chmod"
  export_cmd "CHOWN" "chown"
  export_cmd "LN" "ln"
  export_cmd "MKDIR" "mkdir"
  export_cmd "CUT" "cut"
  export_cmd "TAR" "tar"
  export_cmd "SYNC" "sync"
  export_cmd "SLEEP" "sleep"
}

alias_cmd

#### end alias command ############################################


#### main script ##################################################


$MOUNT -o remount,rw rootfs /

## begin su create.

$CP -f /system/bootmenu/binary/su /su
$CHOWN 0.0 /su
$CHMOD 6755 /su

## end su create.

## begin /default.prop replace..

$RM /default.prop
$CP -f /system/bootmenu/config/default.prop /default.prop

## end /default.prop replace..


## begin /sbin/adbd replace..

$CP -f /system/bootmenu/binary/adbd /sbin/adbd.root
$CHMOD 755 /sbin/adbd.root

## end /sbin/adbd replace..

## begin /sbin/busybox create.

$CP -f /system/bootmenu/binary/busybox /sbin/
$CHMOD 755 /sbin/
$CHMOD 755 /sbin/busybox
$CHOWN 0.0 /sbin/busybox

## end /sbin/busybox create.


## begin busybox sym link..

$LN -s /sbin/busybox /sbin/[
$LN -s /sbin/busybox /sbin/[[
$LN -s /sbin/busybox /sbin/ash
$LN -s /sbin/busybox /sbin/awk
$LN -s /sbin/busybox /sbin/basename
$LN -s /sbin/busybox /sbin/bbconfig
$LN -s /sbin/busybox /sbin/bunzip2
$LN -s /sbin/busybox /sbin/bzcat
$LN -s /sbin/busybox /sbin/bzip2
$LN -s /sbin/busybox /sbin/cal
$LN -s /sbin/busybox /sbin/cat
$LN -s /sbin/busybox /sbin/catv
$LN -s /sbin/busybox /sbin/chgrp
$LN -s /sbin/busybox /sbin/chmod
$LN -s /sbin/busybox /sbin/chown
$LN -s /sbin/busybox /sbin/chroot
$LN -s /sbin/busybox /sbin/cksum
$LN -s /sbin/busybox /sbin/clear
$LN -s /sbin/busybox /sbin/cmp
$LN -s /sbin/busybox /sbin/cp
$LN -s /sbin/busybox /sbin/cpio
$LN -s /sbin/busybox /sbin/cut
$LN -s /sbin/busybox /sbin/date
$LN -s /sbin/busybox /sbin/dc
$LN -s /sbin/busybox /sbin/dd
$LN -s /sbin/busybox /sbin/depmod
$LN -s /sbin/busybox /sbin/devmem
$LN -s /sbin/busybox /sbin/df
$LN -s /sbin/busybox /sbin/diff
$LN -s /sbin/busybox /sbin/dirname
$LN -s /sbin/busybox /sbin/dmesg
$LN -s /sbin/busybox /sbin/dos2unix
$LN -s /sbin/busybox /sbin/du
$LN -s /sbin/busybox /sbin/echo
$LN -s /sbin/busybox /sbin/egrep
$LN -s /sbin/busybox /sbin/env
$LN -s /sbin/busybox /sbin/expr
$LN -s /sbin/busybox /sbin/false
$LN -s /sbin/busybox /sbin/fdisk
$LN -s /sbin/busybox /sbin/fgrep
$LN -s /sbin/busybox /sbin/find
$LN -s /sbin/busybox /sbin/fold
$LN -s /sbin/busybox /sbin/free
$LN -s /sbin/busybox /sbin/freeramdisk
$LN -s /sbin/busybox /sbin/fuser
$LN -s /sbin/busybox /sbin/getopt
$LN -s /sbin/busybox /sbin/grep
$LN -s /sbin/busybox /sbin/gunzip
$LN -s /sbin/busybox /sbin/gzip
$LN -s /sbin/busybox /sbin/head
$LN -s /sbin/busybox /sbin/hexdump
$LN -s /sbin/busybox /sbin/id
$LN -s /sbin/busybox /sbin/insmod
$LN -s /sbin/busybox /sbin/install
$LN -s /sbin/busybox /sbin/kill
$LN -s /sbin/busybox /sbin/killall
$LN -s /sbin/busybox /sbin/killall5
$LN -s /sbin/busybox /sbin/length
$LN -s /sbin/busybox /sbin/less
$LN -s /sbin/busybox /sbin/ln
$LN -s /sbin/busybox /sbin/losetup
$LN -s /sbin/busybox /sbin/ls
$LN -s /sbin/busybox /sbin/lsmod
$LN -s /sbin/busybox /sbin/lspci
$LN -s /sbin/busybox /sbin/lsusb
$LN -s /sbin/busybox /sbin/lzop
$LN -s /sbin/busybox /sbin/lzopcat
$LN -s /sbin/busybox /sbin/md5sum
$LN -s /sbin/busybox /sbin/mkdir
$LN -s /sbin/busybox /sbin/mke2fs
$LN -s /sbin/busybox /sbin/mkfifo
$LN -s /sbin/busybox /sbin/mkfs.ext2
$LN -s /sbin/busybox /sbin/mknod
$LN -s /sbin/busybox /sbin/mkswap
$LN -s /sbin/busybox /sbin/mktemp
$LN -s /sbin/busybox /sbin/modprobe
$LN -s /sbin/busybox /sbin/more
$LN -s /sbin/busybox /sbin/mount
$LN -s /sbin/busybox /sbin/mountpoint
$LN -s /sbin/busybox /sbin/mv
$LN -s /sbin/busybox /sbin/nice
$LN -s /sbin/busybox /sbin/nohup
$LN -s /sbin/busybox /sbin/od
$LN -s /sbin/busybox /sbin/patch
$LN -s /sbin/busybox /sbin/pgrep
$LN -s /sbin/busybox /sbin/pidof
$LN -s /sbin/busybox /sbin/pkill
$LN -s /sbin/busybox /sbin/printenv
$LN -s /sbin/busybox /sbin/printf
$LN -s /sbin/busybox /sbin/ps
$LN -s /sbin/busybox /sbin/pwd
$LN -s /sbin/busybox /sbin/rdev
$LN -s /sbin/busybox /sbin/readlink
$LN -s /sbin/busybox /sbin/realpath
$LN -s /sbin/busybox /sbin/renice
$LN -s /sbin/busybox /sbin/reset
$LN -s /sbin/busybox /sbin/rm
$LN -s /sbin/busybox /sbin/rmdir
$LN -s /sbin/busybox /sbin/rmmod
$LN -s /sbin/busybox /sbin/run-parts
$LN -s /sbin/busybox /sbin/sed
$LN -s /sbin/busybox /sbin/seq
$LN -s /sbin/busybox /sbin/setsid
$LN -s /sbin/busybox /sbin/sh
$LN -s /sbin/busybox /sbin/sha1sum
$LN -s /sbin/busybox /sbin/sha256sum
$LN -s /sbin/busybox /sbin/sha512sum
$LN -s /sbin/busybox /sbin/sleep
$LN -s /sbin/busybox /sbin/sort
$LN -s /sbin/busybox /sbin/split
$LN -s /sbin/busybox /sbin/stat
$LN -s /sbin/busybox /sbin/strings
$LN -s /sbin/busybox /sbin/stty
$LN -s /sbin/busybox /sbin/swapoff
$LN -s /sbin/busybox /sbin/swapon
$LN -s /sbin/busybox /sbin/sync
$LN -s /sbin/busybox /sbin/sysctl
$LN -s /sbin/busybox /sbin/tac
$LN -s /sbin/busybox /sbin/tail
$LN -s /sbin/busybox /sbin/tar
$LN -s /sbin/busybox /sbin/tee
$LN -s /sbin/busybox /sbin/test
$LN -s /sbin/busybox /sbin/time
$LN -s /sbin/busybox /sbin/top
$LN -s /sbin/busybox /sbin/touch
$LN -s /sbin/busybox /sbin/tr
$LN -s /sbin/busybox /sbin/true
$LN -s /sbin/busybox /sbin/tty
#### Custom recovery ....
#### $LN -s /sbin/busybox /sbin/tune2fs
$LN -s /sbin/busybox /sbin/umount
$LN -s /sbin/busybox /sbin/uname
$LN -s /sbin/busybox /sbin/uniq
$LN -s /sbin/busybox /sbin/unix2dos
$LN -s /sbin/busybox /sbin/unlzop
$LN -s /sbin/busybox /sbin/unzip
$LN -s /sbin/busybox /sbin/uptime
$LN -s /sbin/busybox /sbin/usleep
$LN -s /sbin/busybox /sbin/uudecode
$LN -s /sbin/busybox /sbin/uuencode
$LN -s /sbin/busybox /sbin/watch
$LN -s /sbin/busybox /sbin/wc
$LN -s /sbin/busybox /sbin/which
$LN -s /sbin/busybox /sbin/whoami
$LN -s /sbin/busybox /sbin/xargs
$LN -s /sbin/busybox /sbin/yes
$LN -s /sbin/busybox /sbin/zcat

## end busybox sym link..

exit
