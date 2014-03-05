#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

echo "\n*** configure-2-distribute-2-gecko"

echo "\n*** find device name"

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

echo "found device $device"

echo "\n*** wiping temporary cert DB"
rm -Rf certdb.tmp

echo "\n*** create new temporary cert DB"
./new_certdb.sh certdb.tmp

echo "\n*** add d2g cert to temporary cert DB"
# TODO: use the DER generaeted by d2g here
./add_or_replace_root_cert.sh certdb.tmp marketplace-dev-public-root

echo "\n*** reset trusted marketplace list on device"
# TODO : put the host name for the d2g service here!
./change_trusted_servers.sh $device \
       "https://marketplace-dev.allizom.org,https://marketplace.allizom.org,https://marketplace.firefox.com"

echo "\n*** push temporary cert DB to device"       
./push_certdb.sh $device certdb.tmp
