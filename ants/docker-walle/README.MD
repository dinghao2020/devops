# 关于walle环境镜像:

#### 集成打包lnmp环境的walle-web部署工具,适合懒人们使用.

#### 环境配置是:
PHP 5.6.23
Nginx 1.10.1

#### 系统组件:
git nginx  gettext libmcrypt-dev icu-libs zlib-dev unzip subversion ansible openssh-client

#### php组件:
bcmath intl mbstring mcrypt mysqli opcache pdo_mysql


### 如何使用?
* build 镜像

```
docker  build -t nginx-php-walle .
```
* 或者直接pull
> docker pull ayaevil/walle-cim

* 使用生成的镜像

```
构建镜像内的命令有初始化，首先要有完整的walle-web 项目代码及依赖
git clone https://github.com/meolu/walle-web.git /tmp/
下载 walle-web.vendor.tgz
https://pan.baidu.com/s/1kU6gdZD
把下载的 walle-web.vendor.tgz 放入 /tmp/walle-web/
cd /tmp/walle-web/ && tar -xf wall-web.vendor.tgz
配置相关的数据库
vim config/local.php
参考：
mysql -uroot -p
CREATE DATABASE walle CHARACTER SET utf8;
CREATE USER 'walle'@'%' IDENTIFIED BY 'walle';
GRANT ALL PRIVILEGES ON walle.* TO 'walle'@'%';
docker  run -d -v /tmp/walle-web:/opt/walle-web  -p 80:80 nginx-php-walle

```

* 其他（内网用户）

```
git clone https://github.com/meolu/walle-web.git /tmp/
wget -c http://192.168.1.91:5892/nginx-php-walle.tar
wget -c http://192.168.1.91:5892/walle-web.vendor.tgz
tar -xf walle-web.vendor.tgz -C /tmp/walle-web/
cd /tmp/walle-web
#配置数据库
vim config/local.php


docker load --input nginx-php-walle.tar
或者
docker load < nginx-php-walle.tar
docker  run -d -v /tmp/walle-web:/opt/walle-web  -p 9999:80 nginx-php-walle
【docker 里默认nginx walle name 是  walle.company.com 】

```
