#!/bin/bash

#curl -L http://etcd01.cimhealth.in:2379/v2/keys/iptable/ip -XPUT -d value="10.27.80.122 10.27.81.54 10.44.157.11 10.44.155.122 10.51.113.73 10.51.98.137 10.51.98.195 10.51.50.89 10.51.90.65 10.27.73.143 10.173.3.68 10.171.37.240 10.171.8.26 10.51.49.99 10.170.175.113 10.172.247.129 10.171.43.118 10.44.24.65 10.171.62.83 10.162.212.6 10.25.90.111 10.170.180.132"
#curl -L http://etcd01.cimhealth.in:2379/v2/keys/iptable/port -XPUT -d value="22,8015,2379,4000,3308,3306,6379"

which http||{ echo "Please install httpie" && exit 0; }
url="http://etcd01.cimhealth.in:2379"
f_ip1=/tmp/server_ip1
f_ip2=/tmp/server_ip2
f_port1=/tmp/server_port1
f_port2=/tmp/server_port2

server_ip=$(http "$url"/v2/keys/iptable/ip|egrep value|awk -F'"' '{print $14}')
server_port=$(http "$url"/v2/keys/iptable/port|egrep value|awk -F'"' '{print $14}')

function clean_iptable(){
    /sbin/iptables -P INPUT ACCEPT
    /sbin/iptables -P OUTPUT ACCEPT
    /sbin/iptables -P FORWARD ACCEPT
    /sbin/iptables -F
    /sbin/iptables -X
    /sbin/iptables -Z
    /sbin/iptables-save
}
function do_iptable(){
    for i in $server_ip;do
        iptables -I INPUT -p TCP -m multiport --destination-port $server_port -s $i -j ACCEPT
    done   
    iptables -I INPUT -p TCP  --destination-port 8731 -s 211.144.0.242 -j ACCEPT
    iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --destination-port $server_port -s 0.0.0.0/0 -j DROP
}
function update_file(){
    echo $server_ip|tee $f_ip1
    echo $server_port|tee $f_port1
    diff $f_ip1 $f_ip2 && diff $f_port1 $f_port2 || { clean_iptable && do_iptable;echo $server_ip|tee $f_ip1 $f_ip2 && echo $server_port|tee $f_port1 $f_port2; }
}
test -f /tmp/server_ip1 || { clean_iptable && do_iptable &&  echo $server_ip|tee $f_ip1 $f_ip2 && echo $server_port|tee $f_port1 $f_port2 &&  exit 0 ; }
update_file
