#!/bin/bash
DOWNLOAD_PREFIX="https://raw.githubusercontent.com/1265578519/cdnbest/main/cdnbest"
OS="6"
if [ -f /usr/bin/systemctl ] ; then
        OS="7"
	if [ -f /usr/bin/dnf ] ; then
		OS="8"
        fi
fi
if [ $# != 1 ] ;then
        echo "usage: download_master.sh version"
        exit 1
fi
wget -O cdnbest-master.tar.gz $DOWNLOAD_PREFIX/cdnbest-master-$1-$OS.tar.gz
ret=$?
if [ $ret != 0 ]; then
        exit $ret
fi
tar xzf cdnbest-master.tar.gz
echo "ready cdnbest-master for you..."
