#!/bin/bash

#check if the script is running under root
if [ $EUID -ne 0 ]; then
	echo " This script must be run as root "
	exit 1
fi
#Environment Config  for CI evnironment
TESTCI=testci.sh
#pacakge version
JAVA=jdk-8u152-linux-x64.tar.gz
MAVEN=apache-maven-3.5.2-bin.tar.gz
TOMCAT=apache-tomcat-8.5.24.tar.gz
NODE=node-v8.9.1-linux-x64.tar
NPM=5.1.1
MONGODB=mongodb-linux-x86_64-ubuntu1604-3.6.1.tgz
PHANTOMJS=phantomjs-2.1.1-linux-x86_64.tar
ROOTCERTIFICATE=RootCertificate.7z

#Download Server
#INTRANET_SERVER=139.24.161.146:8000
INTRANET_SERVER=139.24.140.251:8000
INTERNET_SERVER=222.92.47.141:8081
PROXY_SERVER=10.193.12.222:63128
#PROXY SETTING FOR APT
APTLOCATION=`pwd`/apt_proxy_conf

#CHECK NETWORK
NET_STATUS="nope"
ping -c 1 `echo $INTERNET_SERVER|cut -d ":" -f1` > /dev/null 2>&1
if [ $? -eq 0 ];then
	NET_STATUS="Internet"
else
	ping -c 1 `echo $INTERANET_SERVER|cut -d ":" -f1` > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		NET_STATUS="Intranet"
	else 
	ping -c 1 `echo $PROXY_SERVER|cut -d ":" -f1` > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		NET_STATUS="Proxy"
	fi
	fi
fi

echo "$NET_STATUS"

function installJava() {
echo "********Begin Install Java"
if [ -f `pwd`/$JAVA ];then
#	tar -zxvf $JAVA -C /opt
	java -version >/dev/null 2>&1
	if [ $? = 0 ];then
		echo "Java is already installed"
	else
	#rm -rf /opt/`ls /opt|grep jdk`
	tar -zxvf $JAVA -C /opt
	JAVA_HOME=/opt/`ls /opt|grep jdk`
	update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 500	
	update-alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 500
	update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 500
	update-alternatives --install /usr/bin/javah javah $JAVA_HOME/bin/javah 500
	update-alternatives --install /usr/bin/javap javap $JAVA_HOME/bin/javap 500
	if [ -f /etc/profile.d/testci.sh ];then
	rm -f /etc/profile.d/testci.sh
	fi
	tee >>/etc/profile.d/testci.sh<<EOF
export JAVA_HOME=$JAVA_HOME
export JRE_HOME=$JAVA_HOME/jre
export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
EOF
	chmod 644 /etc/profile.d/testci.sh
	#export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
	echo "******** JAVA Installation Complete"
	fi
else
	echo "********Installation Package not found in local folder"
fi
}

installJava


function installNode(){
echo "********Begin Install Node"
if [ -f `pwd`/$NODE ];then
		node -v >/dev/null 2>&1
		if [ $? = 0 ]; then
			echo "Nodejs is installed"
		else
		#tar --strip-components 1 -zxvf $NODE -C /usr/local
		xz -d $NODE
		tar --strip-components 1 -xvf $NODE -C /usr/local 
		echo "********Nodejs Installation Complete"
		fi	
else
	echo "********Installation Package not found in local folder"
fi
}

installNode

#this setup the npm config under root account. Please run another script npmconfig.sh to config npm under Jenkins
function npminstall(){
if [ $NET_STATUS = "Proxy" ];then
	npm config set registry http://registry.npm.taobao.org/
	npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass
	npm config set chromedriver https://npm.taobao.org/mirrors/chromedriver
	npm config set node_mirror https://npm.taobao.org/mirrors/node
	npm config set npm_mirror https://npm.taobao.org/mirrors/npm
	npm config set proxy http://$PROXY_SERVER 
#	apt-get -c $APT install python-minimal
	if [ -e `pwd`/apt_proxy_conf ];then
		apt-get -c `pwd`/apt_proxy_conf install python-minimal
	else
		apt-get -o Acquire::http::proxy "http://$PROXY_SERVER" install python-minimal
	fi
elif [ $NET_STATUS = "Intranet"];then
	npm config set registry http://10.192.29.28:8081/repository/npm/
	npm config set sass_binary_site https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/node-sass
	npm config set phantomjs_cdnurl https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/phantomjs
	npm config set chromedriver_cdnurl https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/chromedriver
	apt-get install  python-minimal
fi
	#npm install -g node-gyp
	ng -v >/dev/null 2>$1
	if [ $? -eq 0 ];then
		echo "********Angular-Cli is installed"
	else
		npm install -g node-gyp
		npm install -g @angular/cli@1.4.9
	fi
}

npminstall


function installMaven(){
echo "********Begin Install Maven"
	if [ -f `pwd`/$MAVEN ];then
		mvn -v >/dev/null 2>&1
		if [ $? = 0 ];then
			echo "Maven is installed"
		else
		tar -zxvf $MAVEN -C /opt
		MAVEN_HOME=/opt/`ls /opt|grep maven`
		tee>>/etc/profile.d/testci.sh<<EOF
export MAVEN_HOME=$MAVEN_HOME
export CLASSPATH=\$CLASSPATH/\$MAVEN_HOME:bin
export PATH=\$PATH:\$MAVEN_HOME/bin
EOF

	echo "********Maven installation Complete"
	fi
else
	echo "********Installation Package Not Found In Local Folder"
fi
}

installMaven

function installMongodb(){
echo "********Begin Install Mongodb"
if [ -f `pwd`/$MONGODB ];then
	mongo -version >/dev/null 2>&1
	if [ $? = 0 ];then
		echo "Mongodb is installed"
	else
	tar -zxvf $MONGODB -C /opt
	tee>>/etc/profile.d/testci.sh<<EOF
export PATH=\$PATH:/opt/`ls /opt|grep mongo`/bin
EOF
	mkdir -p /data/db
	echo "********Mongodb Installation Complete"
	fi
else
	echo "********Installation Package Not Found In Local Folder"
fi
} 

installMongodb

function installTomcat(){
echo "*******Begin Install Tomcat"
if [ -f `pwd`/$TOMCAT ];then
	if [ -e /opt/tomcat ];then
		echo "Tomcat is installed"
	else
	tar -zxvf $TOMCAT -C /opt/
	echo "******Tomcat Installation Complete"
	fi
else
	echo "******Installation Package Not Found In Local Folder"
fi
}
	
installTomcat

function installPhantomjs(){
echo "********Begin Install PhantomJs"
if [ -f `pwd`/$PHANTOMJS ];then
	phantomjs -version >/dev/null 2>&1
	if [ $? = 0 ];then
		echo "Phantomjs is installed"
	else
	tar -xvf $PHANTOMJS -C /opt
	tee>>/etc/profile.d/testci.sh<<EOF
export PATH=\$PATH:/opt/`ls /opt|grep phantom`/bin
EOF
	echo "********Phantomjs Installation Complete"
	fi
else
	echo "********Installation Package Not Found In Local Folder"
fi
} 

installPhantomjs

source /etc/profile.d/testci.sh

function installCertificate(){
echo "********Begin Install Siemens Certificate"
if [ -f `pwd`/$ROOTCERTIFICATE ];then
	apt-get -c `pwd`/apt_proxy_conf install p7zip-full
	#apt-get -o Acquire::http::proxy "http://$PROXY_SERVER" install p7zip-full
	7z x $ROOTCERTIFICATE
	keytool -import -alias SiemensRootCAV3 -file "`pwd`/SiemensRootCA_V3.0_2016.cer" -keystore "$JAVA_HOME/jre/lib/security/cacerts"
	keytool -import -alias SiemensCAIntranetServer2016 -file "`pwd`/SiemensIssuing_CA_IntranetServer_2016.cer" -keystore "$JAVA_HOME/jre/lib/security/cacerts"
else
	echo "********Siemens Certificate Not Found In Local Folder"
fi
}

installCertificate


#source /etc/profile.d/testci.sh

#mv settings.xml to /opt/maven/conf/
if [ -e `pwd`/settings.xml ];then
	mv `pwd`/settings.xml /opt/`ls /opt|grep maven`/conf
	if [ $? -eq 0 ];then
		echo "Successfully setup Maven config"
	else
		echo " Set Maven Setting.xml fail, please do it manually"
	fi
else
	echo "Missing settings.xml file"
fi
		
	

	



