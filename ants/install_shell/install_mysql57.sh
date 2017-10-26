#!/bin/bash 

/usr/sbin/setenforce 0
sed -i 's/enforcing/disabled/'  /etc/selinux/config
wget https://repo.mysql.com//mysql57-community-release-el7-11.noarch.rpm
yum localinstall mysql57-community-release-el7-11.noarch.rpm
yum repolist enabled | grep "mysql.*-community.*"
yum repolist all | grep mysql
yum install mysql-community-server

cat >> /etc/my.cnf << EOF

server_id = 1
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
default-storage-engine=INNODB
#Optimize omit
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
log-bin     = binlog
log_bin_trust_function_creators=1
binlog_format = ROW
expire_logs_days = 99
sync_binlog = 0
slow-query-log=1
slow-query-log-file=/var/log/mysql.slow-queries.log
long_query_time = 3
log-queries-not-using-indexes
explicit_defaults_for_timestamp = 1
EOF

sleep 1
systemctl start mysqld
systemctl status mysqld

old_pwd=$(grep 'temporary password' /var/log/mysqld.log |awk '{print $NF}')
echo -ne "\033[31m mysql new_password is \033[0m"  "\033[43;37m Mysql@123456 \033[0m" "\n"
mysql -uroot -p${old_pwd} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Mysql@123456'";
