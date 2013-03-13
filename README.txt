This directory contains scripts for customizing the certificate trust database
so that additional app stores can be added *for testing purposes only*. Gecko
does not properly support multiple app stores signing privileged apps, so these
scripts *cannot and should not* be used to add support for privileged apps from
stores for production purposes.

Example usage:

  rm -Rf certdb.tmp
  ./new_certdb.sh certdb.tmp
  ./add_or_replace_root_cert.sh certdb.tmp root-ca-reviewers-marketplace
  ./change_trusted_servers.sh full_unagi \
         "https://marketplace-dev.allizom.org,https://marketplace.firefox.com"
  ./push_certdb.sh full_unagi certdb.tmp

If you want to add marketplace-dev support, add one or both of these before
executing push_certdb.sh

  ./add_or_replace_root_cert.sh certdb.tmp marketplace-dev-public-root
  ./add_or_replace_root_cert.sh certdb.tmp marketplace-dev-reviewers-root
  
These steps are done in separate scripts so that add_or_replace_root_cert.sh
can be used for B2G desktop, which doesn't require the push/pull steps.

You must have the the Android SDK and NSS tools in your path.

Android ADT (SDK): http://developer.android.com/sdk/index.html
After you install the SDK, add $ADT/sdk/platform-tools to your path.

Debian/Ubuntu: sudo apt-get install libnss3-tools
Fedora       : su -c "yum install nss-tools"
openSUSE     : sudo zypper install mozilla-nss-tools 

Windows:

   hg clone https://hg.mozilla.org/projects/nspr
   hg clone https://hg.mozilla.org/projects/nss
   cd nss
   OS_TARGET=WIN95 make nss_build_all
   cd ..
   export NSS=$PWD/dist/WIN954.0_DBG.OBJ
   # NSS/bin must be ahead of the rest of the path because NSS and Windows both
   # have tools called "certutil".
   export PATH=$NSS/bin:$NSS/lib:$PATH
