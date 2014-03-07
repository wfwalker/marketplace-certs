#!/bin/sh

device="$1"

echo "\n*** ensure this phone is ready for d2g"

if [ -z "$device" ]; then
  echo "usage: ./check_device.sh <device>"
  echo
  echo "<device> will usually be \"full_unagi\""
  exit 1
fi

# Be nice and wait for the user to connect the device
adb -s $device wait-for-device

# get prefs from phone
adb pull /system/b2g/defaults/pref/user.js user-old.js 

#find the crucial line
grep "dom.mozApps.signed_apps_installable_from" user-old.js
found=$?
if [ $found -eq 1 ]; then
	echo "\n*** this phone does not have a value for dom.mozApps.signed_apps_installable_from in /system/b2g/defaults/pref/user.js"
fi

# retrieve the certdb
rm -rf foundcertdb
./pull_certdb.sh $device foundcertdb

#look for d2g-public-key
NSS_DEFAULT_DB_TYPE=sql certutil -L -d foundcertdb > foundcertdb-index.txt

grep "d2g-public-key" foundcertdb-index.txt
found=$?

if [ $found -eq 1 ]; then
	echo "\n*** this phone does not have a d2g-public-key in its cert database"
fi


