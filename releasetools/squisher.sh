# This script is included in squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/RomManager.apk
rm -f $REPACK/ota/system/xbin/irssi

mkdir -p $REPACK/ota/system/etc/terminfo/x
cp $REPACK/ota/system/etc/terminfo/l/linux $REPACK/ota/system/etc/terminfo/x/xterm

# prebuilt boot, devtree, logo & updater-script
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/boot-222-179-4.smg $REPACK/ota/boot.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/devtree-222-179-2.smg $REPACK/ota/devtree.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/logo-moto.raw $REPACK/ota/logo.img
cp -f $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script $REPACK/ota/META-INF/com/google/android/updater-script
if [ -n "$CYANOGEN_RELEASE" ]; then
  cat $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script-rel >> $REPACK/ota/META-INF/com/google/android/updater-script
fi
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/root/init $REPACK/ota/system/bootmenu/2nd-init/init
cp -f $ANDROID_BUILD_TOP/out/target/product/jordan/root/init.rc $REPACK/ota/system/bootmenu/2nd-init/init.rc

