#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

# For use by a sysadmin or a tester; configures a phone to do beta testing
# of privileged open web apps

# see https://github.com/wfwalker/marketplace-certs
# see https://github.com/digitarald/d2g
# see https://wiki.mozilla.org/Marketplace/Reviewers/Apps/InstallingReviewerCerts

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

echo "\n*** fetch DER from d2g server at $d2gHostname"
derFileURL="http://$d2gHostname/cert"
wget $derFileURL -O d2g-public-key.der
wgetResponse=$?

if [ $wgetResponse -ne 0 ]; then
	echo "could not download DER file from $derFileURL, check your hostname and server and try again"
	exit 1
fi

echo "\n*** add d2g cert to temporary cert DB"
./add_or_replace_root_cert.sh certdb.tmp d2g-public-key

echo "\n*** find device name"
device=`./find_device_name.sh`
if [ $device == 'unknown' ]; then
	echo "Firefox OS device not found."
	echo "Please connect your device via ADB, turn it on, unlock it, enable remote debugging, and try again"

	exit 1
else
	echo "found device $device"
fi

echo "\n*** push temporary cert DB to device $device"       
./push_certdb.sh $device certdb.tmp

echo "\n*** reset trusted marketplace list on device $device to http://$d2gHostname"
./change_trusted_servers.sh $device "http://$d2gHostname"

