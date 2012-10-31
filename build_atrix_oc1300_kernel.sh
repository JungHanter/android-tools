#!/bin/bash -e
export LINUXSRCDIR=$(pwd)/kernel-MB860
export ANDROID_BUILD_TOP=$(pwd)

MY_UPDATE="my_update"
ATRIX_BOOT_FILES_SUSTEM="$(dirname $0)/atrix-boot.img-ramdisk.gz"
MY_KERNEL="kernel-MB860"
WIFI_DRIVER="olympus-wifi-module/open-src/src/dhd/linux"
WIFI_MODULE="vendor"
OLD_PWD=`pwd`

if [ ! -d $MY_UPDATE ]; then
	mkdir -p $MY_UPDATE
fi

cd $MY_KERNEL
make zImage
make modules
cd $OLD_PWD
zImage=`find $MY_KERNEL -name "zImage"`
echo "Build boot.img ..."
mkbootimg --kernel $zImage --ramdisk $ATRIX_BOOT_FILES_SUSTEM -o boot.img
echo "Instal boot.img ..."
mv -v boot.img $MY_UPDATE
echo "Install Modules ... "
if [ ! -d $MY_UPDATE/system/lib/modules ]; then
	mkdir -p $MY_UPDATE/system/lib/modules
fi
modules=`find $MY_KERNEL -name "*.ko"`
for i in $modules; do \
	cp -v $i $MY_UPDATE/system/lib/modules
done

if [ ! -d $WIFI_MODULE/bcm/wlan/osrc/open-src/src/dhd/linux ]; then
	mkdir -p $WIFI_MODULE/bcm/wlan/osrc/open-src/src/dhd/linux 
fi
cd $WIFI_DRIVER
make
cd $OLD_PWD
echo "Install wifi driver ..."
module=`find $WIFI_MODULE -name "*.ko"`
cp -v $module $MY_UPDATE/system/lib/modules

cd $MY_UPDATE
7za a ../kernel_oc1300-cm10-`date +%Y%m%d%H%M`-clotai-olympus.zip *
cd $OLD_PWD

rm -rfv $MY_UPDATE

