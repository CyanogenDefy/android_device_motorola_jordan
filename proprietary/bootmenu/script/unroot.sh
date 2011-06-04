#!/sbin/sh

######## BootMenu Script v0.8.0
######## Execute [Root/Unroot] Menu


export PATH=/sbin:/system/xbin:/system/bin

remove_superuser()
{
  mv /data/data/com.noshufou.android.su /system/bootmenu/ext/
  rm /system/bin/su
  rm /system/xbin/su
  rm /system/app/[Ss][Uu][Pp][Ee][Rr][Uu][Ss][Ee][Rr].[Aa][Pp][Kk]
}

restore_superuser()
{
  cp /system/bootmenu/ext/su /system/bin/
  cp /system/bootmenu/ext/su /system/xbin/
  cp /system/bootmenu/ext/Superuser.apk /system/app/
  mv /system/bootmenu/ext/com.noshufou.android.su /data/data/
  chmod 6755 /system/bin/su
  chmod 6755 /system/xbin/su
  chmod 644 /system/app/Superuser.apk
}

######## Main Script

ls /system/app/[Ss][Uu][Pp][Ee][Rr][Uu][Ss][Ee][Rr].[Aa][Pp][Kk] # hehe..
ret=$?

if [ $ret -eq 0 ]; then
  remove_superuser
else
  restore_superuser
fi

exit
