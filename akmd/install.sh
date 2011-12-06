# use ". install.sh"

#!/bin/bash

#set -e
#cd $(dirname $0)
mm -B

adb remount
adb push akmd.sh /system/bin/akmd2
adb push $ANDROID_BUILD_TOP/out/target/product/jordan/system/bin/akmd.free /system/bin/akmd.free
adb shell killall -TERM akmd2 akmd.free

