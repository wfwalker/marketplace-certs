#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

if [ $# -ne 1 ]; then
	echo "usage: configure-2-distribute-2-gecko.sh <hostname>"
	exit 1
else
	d2gHostname=$1
fi

echo "\n*** configure-2-distribute-2-gecko"

echo "\n*** wiping temporary cert DB"
rm -Rf certdb.tmp

echo "\n*** create new temporary cert DB"
./new_certdb.sh certdb.tmp

echo "\n*** fetch DER from d2g server"
echo "wget $d2gHostname/publicKey.der"

echo "\n*** add d2g cert to temporary cert DB"
# TODO: use the DER generaeted by d2g here
./add_or_replace_root_cert.sh certdb.tmp marketplace-dev-public-root

echo "\n*** find device name"

deviceList="$(adb devices)"

IFS='
'

device='unknown'

for line in $deviceList; do
	[[ $line =~ [0-9]*device$ ]] && device=${line%%device}
done

if [ $device == 'unknown' ] ; then
	echo "Firefox OS device not found."
	echo "Please connect your device via ADB, turn it on, unlock it, enable remote debugging, and try again"
	exit 1
fi

echo "found device $device"

echo "\n*** reset trusted marketplace list on device $device to https://$d2gHostname"
# TODO : put the host name for the d2g service here!
./change_trusted_servers.sh $device "https://$d2gHostname"

echo "\n*** push temporary cert DB to device $device"       
./push_certdb.sh $device certdb.tmp
