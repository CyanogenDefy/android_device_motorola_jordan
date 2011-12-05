# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/RomManager.apk
# rm -f $REPACK/ota/system/xbin/irssi

# these scripts are not required
rm $REPACK/ota/system/etc/init.d/03firstboot
rm $REPACK/ota/system/etc/init.d/04modules

# add an empty script to prevent logcat errors (moto init.rc)
touch $REPACK/ota/system/bin/mount_ext3.sh
chmod +x $REPACK/ota/system/bin/mount_ext3.sh

mkdir -p $REPACK/ota/system/etc/terminfo/x
cp $REPACK/ota/system/etc/terminfo/l/linux $REPACK/ota/system/etc/terminfo/x/xterm

# prebuilt boot, devtree, logo & updater-script
rm -f $REPACK/ota/boot.img
cp -f $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script $REPACK/ota/META-INF/com/google/android/updater-script
if [ -n "$CYANOGEN_RELEASE" ]; then
  cat $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script-rel >> $REPACK/ota/META-INF/com/google/android/updater-script
  cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/boot-234-134.smg $REPACK/ota/boot.img
  cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/devtree-234-134.smg $REPACK/ota/devtree.img
  cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/logo-moto.raw $REPACK/ota/logo.img
fi
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/root/init $REPACK/ota/system/bootmenu/2nd-init/init
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/root/init.rc $REPACK/ota/system/bootmenu/2nd-init/init.rc
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/root/sbin/adbd $REPACK/ota/system/bin/adbd

# use the static busybox in bootmenu, this helps a lot on incomplete roms and ics
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/utilities/busybox $REPACK/ota/system/bootmenu/binary/busybox

