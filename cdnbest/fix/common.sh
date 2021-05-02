#!/bin/bash
KANGLE_VERSION=3.5.21.16

OS="6"
if [ -f /usr/bin/systemctl ] ; then
	OS="7"
fi
ARCH=$OS
if test `arch` = "x86_64"; then
        ARCH="$ARCH-x64"
fi
BIND_ADDRESS="0.0.0.0"
if [ -z $CB_MASTER ] ; then
	BIND_ADDRESS="127.0.0.1"
fi
function disable_selinux()
{
        setenforce 0
        sed -i "s#SELINUX=.*#SELINUX=disabled#" /etc/selinux/config
}
function create_db_password()
{
        db_password=`tr -cd a-zA-Z0-9 </dev/urandom | head -c 16`
        echo "create db password [$db_password]"
        echo $db_password > ~/.db_password
}
function yum_install()
{
	#prepare
	yum -y install epel-release wget bzip2
	#used by php
        yum -y install make automake gcc gcc-c++ pcre-devel zlib-devel sqlite-devel openssl-devel readline-devel libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libmcrypt-devel
	#install other
        yum -y install beanstalkd nscd
	#install java
	if [ $OS = "6" ] ; then
		yum -y install java-1.8.0-openjdk-devel 
		cat > /etc/sysconfig/beanstalkd << END
BEANSTALKD_ADDR=$BIND_ADDRESS
BEANSTALKD_PORT=11300
BEANSTALKD_USER=beanstalkd
END
	else
		yum -y install java-11-openjdk-devel
		cat > /etc/sysconfig/beanstalkd << END
ADDR=-l $BIND_ADDRESS
PORT=-p 11300
USER=-u beanstalkd
END
	fi
        chkconfig beanstalkd on
	chkconfig nscd on
        service beanstalkd start
	service nscd start
}

function setup_system()
{
	mkdir -p $DEST_DIR/kangle/ext/
    	if [ ! -f $DEST_DIR/cbmaster/web2/ssl.crt ] ; then
		cp $DEST_DIR/cbmaster/etc/server.crt $DEST_DIR/cbmaster/web2/ssl.crt
		cp $DEST_DIR/cbmaster/etc/server.key $DEST_DIR/cbmaster/web2/ssl.key
	fi
	cat > $DEST_DIR/kangle/ext/cbmaster.xml << END
<config>
	<server name='ajp' proto='ajp' host='127.0.0.1' port='8009' life_time='10' />
	<api name='multiproxy' file='$DEST_DIR/cbmaster/bin/multiproxy.so'  life_time='60' max_error_count='5'>
        </api>
        <vh name='cbmaster2' doc_root='$DEST_DIR/cbmaster/web2'  inherit='on' app='1' log_file='$DEST_DIR/cbmaster/var/access2.log' log_rotate_size='100M' logs_size='2G' certificate='$DEST_DIR/cbmaster/web2/ssl.crt' certificate_key='$DEST_DIR/cbmaster/web2/ssl.key' http2='1' access="access.xml">
                <bind>!*:80</bind>
                <bind>!*:82</bind>
                <bind>!*:4430s</bind>
                <index id='90' file='index.html'/>
                <map path='/' extend='server:ajp' confirm_file='2' allow_method='*'/>
                <host dir='wwwroot'>*</host>
        </vh>
	<vh name='multiproxy' doc_root='www'  inherit='off' app='1' access='-'>
		<map path='/proxy' extend='api:multiproxy' confirm_file='0' allow_method='*'/>
                <bind>!127.0.0.1:8000</bind>
		<host>*</host>
		<request action='allow' >
			<table name='BEGIN'>
				<chain  action='continue' >
					<mark_timeout   v='6'></mark_timeout>
				</chain>
			</table>
		</request>
	</vh>
</config>
END
	if [ -z $CB_MASTER ] ; then
		sed "s?SED_BASE_PATH?$DEST_DIR?" $DEST_DIR/cbmaster/dist/boot.sh-dist > $DEST_DIR/boot.sh
		sed "s?SED_BASE_PATH?$DEST_DIR?" $DEST_DIR/cbmaster/dist/cbmaster.cron-dist > /etc/cron.d/cbmaster.cron
	else
		sed "s?SED_BASE_PATH?$DEST_DIR?" $DEST_DIR/cbmaster/dist/boot-node.sh-dist > $DEST_DIR/boot.sh
	fi
        chmod 755 $DEST_DIR/boot.sh
}
function disable_firewall()
{
	if [ $OS = "6" ] ; then
		service iptables stop
		chkconfig iptables off
	elif [ $OS = "7" ] ; then
		systemctl stop firewalld
		systemctl disable firewalld
	fi
}
function stop_system()
{
	if [ -z $CB_MASTER ] ; then
		$DEST_DIR/kangle/bin/kangle -q
		$DEST_DIR/cbmaster/bin/daemon -l /var/run/cdnbest-mail.pid -q
		$DEST_DIR/cbmaster/bin/daemon -l /var/run/cdnbest-ssl.pid -q
		$DEST_DIR/cbmaster/bin/daemon -l /var/run/cdnbest-web.pid -q
	fi
        $DEST_DIR/cbmaster/bin/daemon -l /var/run/dnsworker.pid -q
        $DEST_DIR/cbmaster/bin/daemon -l /var/run/cbmaster.pid -q
	if [ ! -z $CB_MASTER ] ; then
		/sbin/iptables -D INPUT -p tcp  -m multiport --dport 3306,11300,2014 -j node_firewall
		/sbin/iptables -F node_firewall
		/sbin/iptables -X node_firewall
	fi
}
function install_kangle()
{
        DOWNLOAD_PREFIX="http://github.itzmx.com/1265578519/cdnbest/main/cdnbest/"
        ARCH="-$OS"
       	if test `arch` = "x86_64"; then
                ARCH="$ARCH-x64"
        fi
        KANGLE_URL="$DOWNLOAD_PREFIX""kangle-cdnbest-$KANGLE_VERSION$ARCH.tar.gz"
        wget $KANGLE_URL -O kangle.tar.gz
        tar xzf kangle.tar.gz
        cat >> kangle/license.txt << END
2
H4sIAAAAAAAAA5Pv5mAAA2bGdoaK//Jw
Lu+hg1yHDHgYLlTbuc1alnutmV304sXT
Jfe6r4W4L3wl0/x376d5VzyPfbeoYd1T
GuZq4nFGinMhz1fGFZVL/wmITGireLB4
dsnsMtVt859fOlutf/eR/1/vm0rGM3KO
ckbtTN504maK75GUSTt31uQK/FrltCPn
cOXlNfU+V5nf1gFtX1iQa9IOpAGFLYQh
ngAAAA==
END
        mkdir kangle/ext
	touch kangle/manage.sec
        cd kangle
        sh install.sh $DEST_DIR/kangle
        cd ..
        rm -rf kangle
        rm -f kangle.tar.gz
}
function install_cbmaster()
{
        mkdir -p $DEST_DIR/cbmaster/etc
cat > $DEST_DIR/cbmaster/etc/config.json << END
{
        "db":"root:$db_password@unix(/var/lib/mysql/mysql.sock)/cdnbest?charset=utf8&clientFoundRows=true",
        "port":"$BIND_ADDRESS:2014",
        "beanstalkd":"127.0.0.1:11300",
        "dnsdun_host":"https://www.dnsdun.com",
        "ipv4":"0.0.0.0:3320",
        "flowratio":0.0,
        "uid":$CB_UID
}
END
        \cp $WORK_DIR/* $DEST_DIR/cbmaster -a
}
function setup_db()
{
	\cp  /etc/my.cnf /etc/my-old.cnf
	cat > /etc/my.cnf << END
[mysqld]
bind-address=$BIND_ADDRESS
binlog-ignore-db = mysql
expire_logs_days = 2
skip-name-resolve
innodb_buffer_pool_size=256M
innodb_file_per_table=1
log-slow-queries = /var/lib/mysql/slowquery.log
long_query_time = 5
symbolic-links=0
max_allowed_packet=200M
max_connections=2000
END
}
function create_db()
{
	mysql -u root mysql -e "delete from user where host!='localhost' or user!='root';update user set host='%' where user='root';create database cdnbest;flush privileges"
        ret=$?
        if [ $ret != 0 ] ; then
                echo "cann't init mysql user"
                exit $ret 
        fi
}
function install_mysql()
{
        #setup mysql
        if [ ! -f /etc/init.d/mysqld ] ; then
                yum -y install mysql-server
                if test $? != 0 ; then
                        echo "install mysql failed-----"
                        sleep 3
                fi
        fi
}
function install_mariadb()
{
	if [ ! -f /usr/libexec/mysqld ] ; then
                yum -y install mariadb-server
                if test $? != 0 ; then
                        echo "install mariadb failed-----"
                fi
        fi
}
function start_db()
{
        if [ $OS = "6" ] ; then
		service mysqld restart
		chkconfig mysqld on
	else
		systemctl start mariadb.service
		systemctl enable mariadb.service
	fi
}
function install_db()
{
        if [ $OS = "6" ]
        then
                install_mysql
        else
                install_mariadb
        fi
	setup_db
	start_db
        create_db
	if [ ! -z $CB_MASTER ] ; then
		create_db_password
		mysqladmin -u root password $db_password
		if [ $? != 0 ] ; then
			echo "cann't change db password to [$db_password]"
		fi
	fi
}
function install_node_firewall()
{
	cat > $DEST_DIR/node_firewall.sh << END
#!/bin/bash
/sbin/iptables -N node_firewall
/sbin/iptables -A node_firewall -s 127.0.0.1 -j ACCEPT
/sbin/iptables -A node_firewall -s $CB_MASTER -j ACCEPT
/sbin/iptables -A node_firewall -j DROP
/sbin/iptables -I INPUT -p tcp  -m multiport --dport 3306,11300,2014 -j node_firewall
END
	chmod 755 $DEST_DIR/node_firewall.sh
}
function install_service()
{
	if [ $OS = "6" ] ; then
        cat > /etc/init/cbmaster.conf << END
start on runlevel [0123456]
exec $DEST_DIR/boot.sh
END
	elif [ $OS = "7" ] ; then
cat > $DEST_DIR/cbmaster.service << END
[Unit]
Description=cdnbest master
After=mariadb.service

[Service]
User=root
Type=forking
ExecStart=$DEST_DIR/boot.sh
ExecStop=$DEST_DIR/cbmaster/shell/stop.sh
#Restart=always

[Install]
WantedBy=multi-user.target
END
	ln -s $DEST_DIR/cbmaster.service /usr/lib/systemd/system/
	systemctl daemon-reload
	systemctl enable cbmaster
	fi
}
function stop_service()
{
	service cbmaster stop
}
function start_service()
{
	if [ $OS = "6" ] ; then
		$DEST_DIR/boot.sh
	elif [ $OS = "7" ] ; then
		service cbmaster start
	fi
}
function install_java()
{
	if [ -f $DEST_DIR/cbmaster/web2/config/application.properties ] ; then
		return
	fi
	cp $DEST_DIR/cbmaster/web2/config/application.properties-dist $DEST_DIR/cbmaster/web2/config/application.properties
	sed -i 's/cdnbest.web.proxy-uid = 0/cdnbest.web.proxy-uid = '$CB_UID'/g' $DEST_DIR/cbmaster/web2/config/application.properties
	ret=$?
	if test $ret != 0 ; then
		echo "update application.properties failed."
		exit $ret
	fi
}
