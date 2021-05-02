#!/bin/bash
DOWNLOAD_PREFIX="http://github.itzmx.com/1265578519/cdnbest/main/cdnbest"
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
#wget -O cdnbest-master.tar.gz $DOWNLOAD_PREFIX/cdnbest-master-$1-$OS.tar.gz
#ret=$?
#if [ $ret != 0 ]; then
#        exit $ret
#fi
#tar xzf cdnbest-master.tar.gz
echo "ready cdnbest-master for you..."
yum -y install glibc.i686 wget tar bzip2
wget $DOWNLOAD_PREFIX/cdnbest-master-$1-$OS.tar.gz.7z.001 -O cdnbest-master.tar.gz.001
wget $DOWNLOAD_PREFIX/cdnbest-master-$1-$OS.tar.gz.7z.002 -O cdnbest-master.tar.gz.002
wget $DOWNLOAD_PREFIX/fix/p7zip_16.02_x86_linux_bin.tar.bz2 -O p7zip_16.02_x86_linux_bin.tar.bz2
tar -xjvf p7zip_16.02_x86_linux_bin.tar.bz2
cd p7zip_16.02/bin
./7za -y x /tmp/cdnbest-master.tar.gz.001
\cp -f cdnbest-master-*.tar.gz /tmp/cdnbest-master.tar.gz
rm -rf cdnbest-master-*.tar.gz
cd /tmp
tar xzf cdnbest-master.tar.gz
rm -rf cdnbest-master.tar.gz.001 cdnbest-master.tar.gz.002 p7zip_16.02_x86_linux_bin.tar.bz2 p7zip_16.02 cdnbest-master.tar.gz
wget $DOWNLOAD_PREFIX/fix/common.sh -O cdnbest-master/shell/common.sh
