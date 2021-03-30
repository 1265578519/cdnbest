安装独立cdn系统，您需提供一台 centos-7 64位 的系统
配置要求：
内存 4G 及以上（最低1G会有点卡）

硬盘 40G 及以上

带宽 2M 及以上

端口放开：
80, 4430, 443, 3320, 3321

1.80,4430,443为主控访问端口，默认安装后主控访问端口为4430.

2.安装完成后，访问地址为https://ip:4430/admin/

3.安装完成后，登陆账号:admin，密码:kangle

4.使用相关文档可查看使用帮助文档


独立系统一键安装脚本:（10086换成您自已帐号的授权uid号）
```
yum -y install wget && cd /tmp && wget http://download.cdnbest.com/cdnbest/download_master.sh -O im.sh && sh im.sh 4.7.25 && ./cdnbest-master/shell/install.sh 10086 /vhs2
```


请注意:
1.安装完成后，如您在云平台有数据，可点击此处 导出数据.待独立系统运行稳定半个月后可到此 清理数据

2.如何同步vip信息.
1.在云平台的用户信息页面的授权码处修改,可随机字符串,长度最好超过16位，修改后的授权码记下来。
2.登陆你的独立主控系统user控制界面，一样在用户信息页面的授权码处修改,将云平台修改的授权码填入，两边的授权码要一致。修改后即可同步vip信息

3.登陆您的独立主控服务器,进入user的用户信息界面,在uid后面有个导入云端数据将云端导出的数据导入即可。

4.重启cdnbest主控程序，以及重启后端程序即可,如您不会操作，可重启整个服务器。如果重启服务器后主控打不开，可登陆主控运行/vhs2/boot.sh命令启动

单独重启主控命令是：systemctl restart cbmaster

5.登陆云平台，在用户信息页面的授权主机处修改你的独立主控ip. 修改完成后在云平台的节点列表将所有节点重启。节点重启后会重新连接到新主控。

云端默认授权主机是：10086.ec.cdnbest.com

6.请注意，安装完，dns域名的信息为空。如果在云平台有数据的需要重新填入域名信息.

7.如果安装完主控，有节点连接不上主控.请按以及步骤检查
1).检查云端的账号有没有设置主控ip.
2).检查主控的3320端口是否是开通的.可用telnet 命令检查
3).登陆节点,运行service cdnbest restart命令重启节点程序
4).联系客服,查看vip设置

独立系统一键升级脚本:
```
cd /tmp && wget http://download.cdnbest.com/cdnbest/download_master.sh -O im.sh && sh im.sh 4.7.25 && ./cdnbest-master/shell/update.sh /vhs2
```


请注意:
1.每次升级前备份好数据库,默认安装的数据库名称为cdnbest,可运行以下命令:
```
mysqldump -u root cdnbest > cdnbest.sql
```

压缩下在下载传输，节省时间
```
yum -y install xz lrzsz
tar -Jcvf cdnbest.sql.tar.xz cdnbest.sql
```

导出数据，导出后下载到本地

2.备份整个安装目录/vhs2  
```
cp -a /vhs2 /vhs2_backup
```


防止升级失败，可将整个目录还原即可恢复。

3.建议定时备份您的数据库.


如需迁移服务器导入恢复sql文件则运行：
```
mysql -u root cdnbest < cdnbest.sql
```

推荐本地主控服务器购买优惠注册
主推阿里云稳定安全：https://www.aliyun.com/product/swas?userCode=kj5ig4dp
腾讯云便宜实惠：https://cloud.tencent.com/act/cps/redirect?redirect=30206&cps_key=e13a24941d2ca9b7a8079c76a22d1bf5


数据运行一段时间正常了根据个人自身需求可以降级成稳定版，取消界面显示的数据导入功能，升级后点击DNS修复一下，同步下DNS数据（4.7.25是开发版，不支持DNS同步，所以点修复没有用，要升级到4.6.16稳定版即可同步解析数据）
```
cd /tmp && wget http://download.cdnbest.com/cdnbest/download_master.sh -O im.sh && sh im.sh 4.6.16 && ./cdnbest-master/shell/update.sh /vhs2
```


ssl证书自动申请需要联系客服索要key填入本地主控系统中才可以自动续期https证书
填写成功后，此时会显示绿灯状态，并且显示这周剩余额度



例如我的，找cdnbest群里别人主控的试了下，是绑定uid的，无法公用同一个key
```
mtg361jsqtceqbqcrxgb158rtcdc1
```







以下为节点安装命令
linux安装

系统要求：Centos-6、7、8.x 64位

安装命令：（复制下面命令到服务器上运行）
```
yum -y install wget;wget --no-check-certificate https://console.cdnbest.com/system/install/10086/4.7.25 -O cb.sh;sh ./cb.sh 10086
```
windows下载

系统要求：windows 2003及以上

[64位下载 ] [ 32位下载 ]
安装成功后，节点会出现在待初始化列表，可点击初始化。
