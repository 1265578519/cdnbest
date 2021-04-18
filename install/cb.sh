#/bin/sh
export CDNBEST_VERSION="4.6.4"
export KANGLE_VERSION="3.5.21.16"

OS="6"
if [ -f /usr/bin/systemctl ] ; then
        OS="7"
        if [ -f /usr/bin/dnf ] ; then
                OS="8"
        fi
fi
if test `arch` != "x86_64"; then
	echo "only support arch x86_64..."
	exit 1
fi
export ARCH="$OS-x64"
export DOWNLOAD_PREFIX="http://github.itzmx.com/1265578519/cdnbest/main/cdnbest"
if ! test $1 ; then
     echo "Error: Please input cdnbest uid"
     exit 1
fi
export CB_UID=$1
cd /tmp/
wget --no-check-certificate $DOWNLOAD_PREFIX/cdnbest-$CDNBEST_VERSION-$ARCH.tar.gz -O cdnbest.tar.gz
ret=$?
if [ $ret != 0 ] ; then
	echo "cann't download file"
	exit $ret
fi
tar xzf cdnbest.tar.gz
cd cdnbest
./shell/install.sh $CB_UID
