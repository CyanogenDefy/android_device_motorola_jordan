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


$KILLALL adbd
$KILLALL adbd.root


$MOUNT -o remount,rw rootfs /
echo 'msc_adb' > /dev/usb_device_mode

PATH=/sbin:/system/xbin:/system/bin:system/bootmenu/binary /sbin/adbd.root &
exit
