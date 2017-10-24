#!/bin/bash

add_hosts(){
	cat >> /etc/hosts <<- EOF
	10.25.90.111	mongo.cimyun.in
	10.172.247.129  etcd.cimyun.in
	10.170.175.113	redis.cimyun.in
	10.170.180.132 mysql01.cimyun.in
	10.25.90.111    etcd01.cimhealth.in
	10.170.175.113	redis01.cimhealth.in
	10.170.180.132  mysql01.cimhealth.in
	211.144.0.243 logstash.cimhealth.in
	10.170.175.113	downfiles.cimhealth.com
	EOF
}

stop_selinux(){
	/usr/sbin/setenforce 0
	sed -i 's/enforcing/disabled/'  /etc/selinux/config
}

install_jdk(){
	wget -c  -O /tmp/jdk.gz  http://downfiles.cimhealth.com/jdk-8u45-linux-x64.gz
	test -d /usr/java || mkdir -pv /usr/java
	tar -xf /tmp/jdk.gz -C /usr/java/
	ln -svf /usr/java/jdk1.* /usr/java/jdk

	cat >> /etc/profile <<- EOF
	export JAVA_HOME=/usr/java/jdk
	export JRE_HOME=\${JAVA_HOME}/jre
	export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib
	export PATH=\${JAVA_HOME}/bin:\$PATH
	EOF

	update-alternatives --install /usr/bin/java java /usr/java/jdk/bin/java 1  
	update-alternatives --install /usr/bin/javac javac /usr/java/jdk/bin/javac 1  
	update-alternatives --install /usr/bin/jar jar /usr/java/jdk/bin/jar 1 


	. /etc/profile
	sleep 1
	java -version && echo "Jdk install success !!! " || echo "Jdk install failed,Please check! "
}

add_users_key(){
	declare -A dic
	dic=()
	dic=([www]="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzZgX3ajOCXYBdluNFlHmDRg5Dd/IJ1otb2sHx+k/IIr5+AK5AVyFlq59hlJZvpdNrxpLXyljLwJj5ZkG0TxnThRCPB6AkzG1HnmWwm4/qa63733OU+b3f0Ju9SfNAg1BnY/MkkgricB/JDaFRaLNgdBMYjTqcDxPeRxWVKbcq9DjynDW+QGOmeeIB9W7I+9GlnhjKbGKsdBaxgdkbAje/7DBjV5MncfY1nhhIpU40V6ow1u/sHXkkgI9R7qKo+pJLqGRqAM4zuYaG+TFV8vBBLBaI6bCvTF4OdvCAWkkZJp0rKK7GN31GLc6vCM+hlKCN0AyOdgRPerUGE474TZ3xw== www.cim120.com.cn" [dinghao]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxo9zbyLzOKHFVyyrVWatKAPuhmzZOGOLsNDlgv7YsnlrRh2VHhyN+JBK04Ms7n12gdybryLYLe4y09AyW/0X7qjwkJi7vv62hGsRh8w4UKfE8q2d5A2P7cK4e+hkVL218N0PpRZ4RuafPbCA7QZnkB+L/8c+0h95iB3GtkohVwk4O3+Vlvpnd3CTXSSRxGTVxSXOmGNdW8vTquChDjeSvt1w0YDakR9osllcHu0Ncy2AjWKV8RS/Y9KLUoRwnWEQ5SjahqWtedKTIPWTw/JQ02yvgzrjfo7ELRxMVcR+pXINbMzeU0D1a+xFY3zxj8y/opNqpJ0N38P7NdPptrRnR dh@dh-pc" [dengtao]='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCX3iJWV8KQ3tCYpAkgMeQk3oQbuKlkLSV6SDWEfZJbxmI6CO991GDiSbsMGTzEDph6En/xqzhMo+Fogv7KvY6atZQ1dzgVlMpnzRtVzw5TGlEVDq9EH/xLjqlY1S9a1cknBb4xl8y7ZEW0KuytHUwNJFoOZ2N+8dOZ2OMoK55ufkzADWdE7iPfCsoVFTAWdu93fqqU0NuwIYdjrdqZ6q5KaO8qqd+OMoTj/diZuw7v4a0UdY/48SxxWkJccu7UWK/Uhss6fYt5HKrN0XBQiI5uOs82mIQkareUK+98kMRQJ3RNYjlP8iX/7FlK9WvMid9fG8Fe8t++YxAmI8dvDOD “taod@oupeng.com”' [yongzhaow]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtS8gyeQpfqxYjtmbCF2i7prPAqC20s58OCVVxioYVNRfm/ywnisuWMCNtrBTmwB9ul4GW9FpBlig3EZiCYZproGb2wxLA5qIthDItK8V4yCJjBwWz1YF/X1kNhAUoGDDxFRZhqbriI9AUNZG3EvIfD11/IxZHzq9vusDZZn1o7YN+aipQpeAwBeB6L4mped3vfEnltE0Ckq28le7U619+AWPzj+EbWQhR1CrDj7kmDhHf3P445U+iuVay0GV3lswvofNhDJ+RQbrT1sWHiRwkQZfyIBFK3pzU9qWoBOnsoVO6bP3FD0R61aiZIdrDmBkR/7/lhorQWDMvT+72A1Y9 yongzhaow@dq")

	grep "%admgroup" /etc/sudoers
	if [ $? == 1 ];then
		chmod u+w /etc/sudoers
		groupadd admgroup
		echo "%admgroup ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
		chmod u-w /etc/sudoers
	fi

	for add_user in $(echo ${!dic[*]})
	do
	    egrep ${add_user} /etc/passwd
	    if [ $? == 1 ];then
	    useradd ${add_user} -m -s /bin/bash -g admgroup
	    su ${add_user} -c"mkdir /home/${add_user}/.ssh && chmod -R 700 /home/${add_user}/.ssh "
	    su ${add_user} -c"echo ${dic[$add_user]} >> /home/${add_user}/.ssh/authorized_keys"
	    su ${add_user} -c"chmod 600 /home/${add_user}/.ssh/authorized_keys" 
	    fi 
	done
}

change_ssh_port(){
	version_number=`awk -F'[ |.]' '{print $4}' /etc/centos-release`
	sed -i 's/#Port 22/Port 8015/' /etc/ssh/sshd_config
	sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
	{ [[ $version_number -ge 7 ]] && systemctl restart sshd ; } || /etc/init.d/sshd restart
}

install_filebeat(){
	wget -c -O /tmp/filebeat.tar.gz  http://downfiles.cimhealth.com/filebeat.tar.gz
	tar -xf /tmp/filebeat.tar.gz -C /usr/local/
	chown -R www.admgroup /usr/local/filebeat-5.1.1-linux-x86_64
	mkdir -pv /data/scripts /data0/logs
	chown -R www.admgroup /data/ /data0/
}

install_nagios(){
	yum update -y
	yum install -y gcc nrpe ntpdate lrzsz rsync
	wget -c -O /tmp/nagios-plugins-2.1.4.tar.gz  http://downfiles.cimhealth.com/nagios-plugins-2.1.4.tar.gz
	tar -xf /tmp/nagios-plugins-2.1.4.tar.gz -C /usr/local/
	{ test -d /usr/local/nagios-plugins-2.1.4 && cd /usr/local/nagios-plugins-2.1.4 ;} || return 0
	./configure --prefix=/usr/local/nagios > /dev/null 2>&1
	make -j `egrep "processor" -c /proc/cpuinfo` > /dev/null 2>&1 
	make install > /dev/null 2>&1
	sed -i 's#/usr/lib64/nagios/plugins#/usr/local/nagios/libexec#g' /etc/nagios/nrpe.cfg 
	sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,10.173.3.68/' /etc/nagios/nrpe.cfg 
	sed -i 's#check_load -w 15,10,5 -c 30,25,20#check_load -w 3,2,1 -c 4,3,2#' /etc/nagios/nrpe.cfg
	sed -i 's#check_procs -w 5 -c 10 -s Z#check_procs -w 1 -c 2 -s Z#' /etc/nagios/nrpe.cfg
	sed -i '/command\[check_hda1\]/a\command[check_disk]=/usr/local/nagios/libexec/check_disk -w 10% -c 5% -A' /etc/nagios/nrpe.cfg 
	sed -i '/command\[check_hda1\]/a\command[check_remote_ntp]=/usr/local/nagios/libexec/check_ntp -H ntp1.cloud.aliyuncs.com -w 1 -c 3' /etc/nagios/nrpe.cfg
	systemctl restart nrpe
	systemctl enable nrpe
}
  
#新服务器ip 访问etcd 会被etcd所在服务器的防火墙解决，下面的函数暂时不能用
register_etcd(){
	which http || yum install httpie -y
	old_ips=`http  http://etcd01.cimhealth.in:2379/v2/keys/iptable/ip|awk -F':|"' '{print $18}'`
	local_ip=`hostname -I|awk '{print $1}'`
	new_ips=`echo $old_ips" "$local_ip`
	curl -L http://etcd01.cimhealth.in:2379/v2/keys/iptable/ip -XPUT -d value="${new_ips}"
}


update_iptables_list(){
	[[ $version_number -ge 7 ]] && { systemctl stop firewalld.service &&  systemctl disable firewalld.service ; yum install -y iptables-services iptables && systemctl enable iptables ; }
	which http || yum install httpie -y
	sed -i '/dport 22/a\-A INPUT -p tcp -m state --state NEW -m tcp --dport 8015 -j ACCEPT' /etc/sysconfig/iptables
	cp /etc/sysconfig/iptables  /etc/sysconfig/iptables_bak
	sed -i '/^-A/d' /etc/sysconfig/iptables
	systemctl restart iptables
	bash -c "$(wget -qO-  http://downfiles.cimhealth.com/etcd_iptables.sh)"
}

install_supervisor(){
	yum -y install python-setuptools
	easy_install supervisor
	echo_supervisord_conf > /etc/supervisord.conf
	mkdir -p /var/log/supervisor
	mkdir -p /var/run/supervisor
	mkdir -p /etc/supervisor/conf.d/
	echo -e "[include]\nfiles = /etc/supervisor/conf.d/*.conf">>/etc/supervisord.conf 
	sed -i 's#/tmp/supervisor.sock#/var/run/supervisor/supervisor.sock#' /etc/supervisord.conf

	cat  > /lib/systemd/system/supervisord.service <<- EOF
	[Unit]
	Description=Supervisord

	[Service]
	Type=forking
	PIDFile=/tmp/supervisord.pid
	ExecStart=/usr/bin/supervisord -c /etc/supervisord.conf
	ExecStop=/bin/kill -TERM \$MAINPID
	ExecReload=/bin/kill -HUP \$MAINPID

	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl enable supervisord
}

rename_host(){
	local_ip=`hostname -I|awk '{print $1}'`
	case $local_ip in
	  10.28.118.91)
	    hostnamectl set-hostname aid-cimhealth
	  ;;
	  10.51.50.89)
	    hostnamectl set-hostname org-comhealth
	  ;;
	esac	
}

#默认是微服务，没有tomcat
add_service_super(){
	which supervisorctl || install_supervisor
	#IP=$(hostname -I|cut  -f2 -d' ')
	project_name=$(hostname|cut -f1 -d"-")

	super_conf(){
	cat > /etc/supervisor/conf.d/"${project_name}".conf <<- EOF
	[program:${project_name}]
	command=/usr/java/jdk/bin/java -jar  /data/scripts/${project_name}/${project_name}-deploy.jar  --spring.profiles.active=deploy -a
	stdout_logfile=/data/scripts/${project_name}/${project_name}.log
	stderr_logfile=/data/scripts/${project_name}/${project_name}.err.log
	autostart=true
	autorestart=true
	user=www
	EOF
	
	cat > /etc/supervisor/conf.d/elk-"$project_name".conf <<- EOF
	[program:elk-$project_name]
	command=/usr/local/filebeat-5.1.1-linux-x86_64/filebeat -e -c /usr/local/filebeat-5.1.1-linux-x86_64/config.yml
	stdout_logfile=/usr/local/filebeat-5.1.1-linux-x86_64/$project_name.log
	stderr_logfile=/usr/local/filebeat-5.1.1-linux-x86_64/$project_name.err.log
	autostart=true
	autorestart=true
	user=www
	EOF
	
		#systemctl restart supervisord
		
	}
	super_conf	
}

#禁止root 远程登陆
prohibit_root_login(){
	sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config || sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i '/^#%PAM-1.0/a\auth       required     pam_tally2.so  deny=3  unlock_time=600 even_deny_root root_unlock_time=1200' /etc/pam.d/sshd
}



# 1 服务器命名
# 2 hosts 添加
# 3 add_user
# 4 filebeat日志转发
# 5 nagios
# 6 jdk
# 7 supervisor
# 8 supervisor 监控的进程
# 9 修改sshd port
# 12 ip 添加到etcd
# 11 iptables update 


rename_host
stop_selinux
add_hosts
add_users_key
install_filebeat
install_nagios
install_jdk
install_supervisor
add_service_super
change_ssh_port
#register_etcd
update_iptables_list  
#prohibit_root_login
