#!/bin/bash -e
usage()
{
cat << EOF

usage: build_aokp_jb.sh manifest_branch revision

manifest_branch: 
	ics, jb

revision:        
	4.1.2_r1

EOF
}

if [ $# -ne 2 ]; then
	usage
	exit 1
fi

AOKP_MANIFEST=https://github.com/clotai/aokp_platform_manifest.git
PREBUILT_MANIFEST=https://github.com/clotai/android_prebuilt_manifest.git
KERNEL_GIT=https://github.com/clotai/android_kernel_motorola_olympus.git

AOKP_KERNEL_DIR=kernel/motorola
KERNEL_DIR=../android_kernel_motorola_olympus

manifest_branch=$1
revision=$2

PREBUILT_DIR=../prebuilt_$revision

# check manifest branch
case $manifest_branch in
	ics|jb)
		;;
	*)
		usage
		exit 1
		;;
esac

# check prebuilt revision
case $revision in
	4.1.2_r1)
		;;
	*)
		usage
		exit 1
		;;
esac

# sync aokp manifest first
echo "repo init my aokp manifest ... "
repo init -u $AOKP_MANIFEST -b $manifest_branch

# sync prebuilt manifest
OLDPWD=`pwd`
if [ ! -d $PREBUILT_DIR ]; then
	echo "repo init my prebuilt manifest ... "
	mkdir -p $PREBUILT_DIR
	cd $PREBUILT_DIR
	repo init -u $PREBUILT_MANIFEST -b $revision
else
	echo "repo sync my prebuilt manifest ... "
	cd $PREBUILT_DIR
	repo sync
fi
cd $OLDPWD

# check if we already get prebuilt
echo "symbolic my prebuilt ... "
DIRS=`ls -d $PREBUILT_DIR/*`
for i in $DIRS; do
	name=`basename $i`
	ln -sf $i $name
done

# repo sync my aokp manifest.
echo "repo sync my aokp manifest ... "
repo sync

# git clone manifest
OLDPWD=`pwd`
if [ ! -d $KERNEL_DIR ]; then
	echo "git clone my kernel ... "
	cd ..
	git clone --depth 1 $KERNEL_GIT
else
	echo "git pull my kernel ... "
	cd $KERNEL_DIR
	git pull
fi

cd $OLDPWD
mkdir -p $AOKP_KERNEL_DIR
result_kernel_dir=`realpath $KERNEL_DIR`
cd $AOKP_KERNEL_DIR
if [ ! -d olympus ]; then
	ln -sf $result_kernel_dir olympus
fi

echo "aokp create successfully"

