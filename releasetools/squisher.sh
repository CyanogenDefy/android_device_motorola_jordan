# This script is included in vendor/cyanogen/tools/squisher
# It is the final build step (after OTA package)

# Delete unwanted apps
rm -f $REPACK/ota/system/app/RomManager.apk

# Location Proxy injection ^^
printf "Injecting smali...(Motorola aGPS)"
(
SMALID=$OUT/smali.d
rm -rf $SMALID
mkdir -p $SMALID
cd $SMALID
unzip $QUIET $REPACK/ota/system/framework/framework.jar "classes.dex"
java -Xmx512m -jar $ANDROID_BUILD_TOP/device/motorola/jordan/releasetools/baksmali.jar classes.dex -o framework
cp -fr $ANDROID_BUILD_TOP/device/motorola/jordan/smali/framework/* framework
java -Xmx512m -jar $ANDROID_BUILD_TOP/device/motorola/jordan/releasetools/smali.jar framework -o classes.dex
zip $QUIET $REPACK/ota/system/framework/framework.jar "classes.dex"
rm -f classes.dex
unzip $QUIET $REPACK/ota/system/framework/services.jar "classes.dex"
java -Xmx512m -jar $ANDROID_BUILD_TOP/device/motorola/jordan/releasetools/baksmali.jar classes.dex -o services
cp -fr $ANDROID_BUILD_TOP/device/motorola/jordan/smali/services/* services
sed -i '/Location Proxy Service/,/I/ c\
    const-string v9, "Starting Location Proxy."\
\
    invoke-static {v5, v9}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I\
\
    const-string v5, "locationproxy"\
\
    new-instance v9, Lcom/android/server/LocationProxyService;\
\
    invoke-direct {v9, v6}, Lcom/android/server/LocationProxyService;-><init>(Landroid/content/Context;)V\
\
    invoke-static {v5, v9}, Landroid/os/ServiceManager;->addService(Ljava/lang/String;Landroid/os/IBinder;)V' services/com/android/server/ServerThread.smali
java -Xmx512m -jar $ANDROID_BUILD_TOP/device/motorola/jordan/releasetools/smali.jar services -o classes.dex
zip $QUIET $REPACK/ota/system/framework/services.jar "classes.dex"
rm -rf $SMALID
)
echo

# prebuilt boo, devtree, logo & updater-script
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/boot-222-179-2.smg $REPACK/ota/boot.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/devtree-222-179-2.smg $REPACK/ota/devtree.img
cp -f $ANDROID_BUILD_TOP/vendor/motorola/jordan/logo-moto.raw $REPACK/ota/logo.img
cp -f $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script $REPACK/ota/META-INF/com/google/android/updater-script
if [ -z "$CYANOGEN_NIGHTLY" ]; then
  cat $ANDROID_BUILD_TOP/device/motorola/jordan/updater-script-rel >> $REPACK/ota/META-INF/com/google/android/updater-script
fi
