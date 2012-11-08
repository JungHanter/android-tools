#!/sbin/sh

echo " "
echo "Symbolic link generator for ROM busybox"
echo "Initial Release (29 Jul 2012)"
echo "sendust7 @ xda developers"
echo " "

if [ $# -ne 1 ]; then
  echo "Usage: sh gen-symlinks-busybox.sh {box_path}"
  echo "Example: sh gen-symlinks-busybox.sh /system/xbin"
  echo "Note: ROM /system partition must be mounted" 
  echo " "
  exit 1
fi

box_path=$1

$box_path/busybox --list > /tmp/busybox.txt

echo "All commands are shown in /tmp/busybox.txt"
echo " "

while read entry; do
  if [ -L $box_path/$entry ] ; then
    rm $box_path/$entry
  fi
  ln -s $box_path/busybox $box_path/$entry

  done < "/tmp/busybox.txt"
                                                                                                                             
