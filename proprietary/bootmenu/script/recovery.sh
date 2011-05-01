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


$MKDIR /tmp
$MKDIR /cache
$MKDIR /pds
$MKDIR /res


#### $MOUNT -o size=5m -t tmpfs tmpfs /tmp

#### /system/bin/mount_ext3.sh cache /cache
#### /system/bin/mount_ext3.sh pds /pds

$RM -f /sdcard
$MKDIR /sdcard

$CHMOD 755 /sbin
$CHMOD 755 /res

$CP -r -f /system/bootmenu/recovery/res/* /res/
$CP -r -f /system/bootmenu/recovery/sbin/* /sbin/

$CHMOD 755 /sbin/*

$RM -f /sbin/postrecoveryboot.sh

/sbin/recovery
exit




