#1/bin/sh

deviceList="$(adb devices)"

IFS='
'

device='unknown'

for line in $deviceList; do
	[[ $line =~ ([0-9]*)device$ ]] && device=${line%%device}
done

if [ $device == 'unknown' ] ; then
	echo "device not found"
	exit 1
fi

echo $device
