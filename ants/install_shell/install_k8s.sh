#!/bin/bash 
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all && yum makecache fast
yum install -y ebtables socat wget curl lrzsz unzip zip 
yum install -y nfs-utils
swapoff -a


cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
sysctl vm.swappiness=0
EOF

sysctl vm.swappiness=0

sysctl --system
systemctl stop firewalld && systemctl disable firewalld
setenforce 0
yum install -y docker
systemctl enable docker && systemctl start docker

[[ -d /opt/img ]] || mkdir -p /opt/img
mount -t nfs 10.130.21.88:/opt/dinghao/ /opt/img
[[ -d /opt/img/k8s ]] || ( echo "挂载失败，退出" && exit 0 )
cd /opt/img/k8s/
for i in `ls`;do docker load < $i;done
#echo '10.130.21.88:/opt/dinghao    /opt/img    nfs    defaults 0 0' >> /etc/fstab

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo '#http_proxy' >> /etc/profile
echo 'export http_proxy=http://10.130.21.188:8118
export NO_PROXY=localhost,127.0.0.1,10.130.21.0/24,mirrors.aliyun.com,*.docker.com,*.mirrors.aliyun.com
export https_proxy=http://10.130.21.188:8118' >> /etc/profile
source /etc/profile

yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
