#!/bin/bash -e
rm -f rom_update-signed.zip rom_update.zip
OLD_PWD=`pwd`
GEN_SH=`pwd`/gen-symlinks-busybox.sh
cd out/target/product/olympus
rm -f system/app/NovaLauncher.apk
rm -f system/etc/permissions/com.google.widevine.software.drm.xml
rm -f `find system -type l`
del_libs="libfrsdk.so libWVphoneAPI.so"
for i in $del_libs; do
rm -f system/lib/$i
done
rm -rf system/media/video
rm -rf system/vendor/lib
if [ "x$1" == "x1" ]; then
mv system/app system/app_bak
mkdir -p system/app
APKS=`ls system/app_bak/*.apk`
for i in $APKS; do
zipalign -f -v 4 $i system/app/`basename $i`;
done
rm -rf system/app_bak
mkdir -p system/xbin/
cp $GEN_SH system/xbin/
7za a ${OLD_PWD}/rom_update.zip system boot.img
cd ${OLD_PWD}
7za a rom_update.zip META-INF
#../android-tools/sign.sh rom_update.zip
else
cd ${OLD_PWD}
fi
