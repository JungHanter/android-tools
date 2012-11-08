#!/bin/bash -e

usage()
{
cat << EOF
Usage: $0 opts [...]

OPTIONS:
   -c      clean unnecessary files
   -p      pack a rom update zip.
EOF
}

clean_rom()
{
	local old_pwd=$1

	cd out/target/product/olympus

	# Remove unnecessary symbolic
	rm -f `find system -type l`

	# unnecessary files
	rm -f system/app/NovaLauncher.apk
	rm -f system/etc/permissions/com.google.widevine.software.drm.xml

	for i in $del_libs; do
		rm -f system/lib/$i
	done

	rm -rf system/media/video
	rm -rf system/vendor/lib

	cd $1
}

pack_rom()
{
	local old_pwd=$1
	local gen_sh=$MY_ANDROID_TOOLS_DIR/gen-symlinks-busybox.sh
	local del_libs="libfrsdk.so libWVphoneAPI.so"
	local apks

	rm -f rom_update-signed.zip rom_update.zip

	clean_rom $old_pwd

	# zipalign apk
	mv system/app system/app_bak
	apks=`ls system/app_bak/*.apk`
	mkdir -p system/app
	for i in $apks; do
		zipalign -f -v 4 $i system/app/`basename $i`;
	done
	rm -rf system/app_bak

	# copy symbolic generator
	mkdir -p system/xbin/
	cp $GEN_SH system/xbin/

	7za a $old_pwd/rom_update.zip system boot.img
	cd $MY_ANDROID_TOOLS_DIR
	7za a $old_pwd/rom_update.zip META-INF
	cd $old_pwd
	sign.sh rom_update.zip
}


OPTIONS=":cp"
OPTERR=0

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

data=($1)
prefix=${data:0:1}

if [ "$prefix" != "-" ]; then
	usage
	exit 1
fi

while getopts $OPTIONS opt; do
	case $opt in
		c)
			clean_rom `pwd`
			;;

		p)
			pack_rom `pwd`
			;;

		:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;

		*)
		usage
		exit 1
		;;

	esac
done


#OLD_PWD=`pwd`
#GEN_SH=`pwd`/gen-symlinks-busybox.sh
#cd out/target/product/olympus
#rm -f system/app/NovaLauncher.apk
#rm -f system/etc/permissions/com.google.widevine.software.drm.xml
#rm -f `find system -type l`
#del_libs="libfrsdk.so libWVphoneAPI.so"
#for i in $del_libs; do
#rm -f system/lib/$i
#done
#rm -rf system/media/video
#rm -rf system/vendor/lib
#if [ "x$1" == "x1" ]; then
#mv system/app system/app_bak
#mkdir -p system/app
#APKS=`ls system/app_bak/*.apk`
#for i in $APKS; do
#zipalign -f -v 4 $i system/app/`basename $i`;
#done
#rm -rf system/app_bak
#mkdir -p system/xbin/
#cp $GEN_SH system/xbin/
#7za a ${OLD_PWD}/rom_update.zip system boot.img
#cd ${OLD_PWD}
#7za a rom_update.zip META-INF
##../android-tools/sign.sh rom_update.zip
#else
#cd ${OLD_PWD}
#fi
