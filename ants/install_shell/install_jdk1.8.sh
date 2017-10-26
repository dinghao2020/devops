#!/bin/bash

echo '123.56.112.3  downfiles.cimhealth.com' >> /etc/hosts
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
install_jdk
