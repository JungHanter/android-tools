#!/bin/bash -e

usage()
{
cat << EOF

usage: sign.sh ifile1 [ifile2...]

EOF
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

wdir=$(dirname $0)

SIGNAPK=${wdir}/signtools/signapk.jar
TESTKEY_PEM=${wdir}/signtools/testkey.x509.pem
TESTKEY_KEY=${wdir}/signtools/testkey.pk8

echo $wdir
exit 1
shift 0

ifiles=$@

for file in $ifiles; do
	filename=${file%.*}
	extension=${file##*.}
	java -jar $SIGNAPK $TESTKEY_PEM $TESTKEY_KEY $file ${filename}-signd.${extension}
done
