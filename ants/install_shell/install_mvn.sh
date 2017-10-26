#!/bin/bash 
#[[ -z $1 ]] && exit 
mvn_version=3.5.0
wget -c http://mirrors.sonic.net/apache/maven/maven-3/3.5.0/binaries/apache-maven-${mvn_version}-bin.tar.gz
tar xzf apache-maven-${mvn_version}-bin.tar.gz -C /usr/local/
cd /usr/local
ln -s apache-maven-${mvn_version} maven

echo -ne " " >> /etc/profile
echo -en "#mave home\n" >> /etc/profile
echo 'MAVEN_HOME=/usr/local/maven
export MAVEN_HOME
export PATH=${PATH}:${MAVEN_HOME}/bin' >> /etc/profile

source /etc/profile
