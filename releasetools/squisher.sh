# This script is included in vendor/cyanogen/tools/squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/RomManager.apk

# prebuilt boo, devtree, logo & updater-script
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/boot-222-179-2.smg $REPACK/ota/boot.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/devtree-222-179-2.smg $REPACK/ota/devtree.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/logo-moto.raw $REPACK/ota/logo.img
cp -f $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script $REPACK/ota/META-INF/com/google/android/updater-script
if [ -z "$CYANOGEN_NIGHTLY" ]; then
  cat $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script-rel >> $REPACK/ota/META-INF/com/google/android/updater-script
fi
