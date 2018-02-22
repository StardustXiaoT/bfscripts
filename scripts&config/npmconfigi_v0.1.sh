#!/bin/bash
##Download Server
#INTRANET_SERVER=139.24.161.146:8000
INTRANET_SERVER=139.24.140.251:8000
INTERNET_SERVER=222.92.47.141:8081
PROXY_SERVER=10.193.12.222:63128
#Local Apt Proxy File
APT=/home/bf/apt_proxy_conf
#Set Env_var

if [ $EUID -eq 0 ];then
	echo "This script must be run under jenkins account, not root account!"
fi

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

function npminstall(){
if [ $NET_STATUS = "Proxy" ];then
	npm config set registry http://registry.npm.taobao.org/
	npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass
	npm config set chromedriver https://npm.taobao.org/mirrors/chromedriver
	npm config set node_mirror https://npm.taobao.org/mirrors/node
	npm config set npm_mirror https://npm.taobao.org/mirrors/npm
	npm config set proxy http://$PROXY_SERVER 
elif [ $NET_STATUS = "Intranet" ];then
	npm config set registry http://10.192.29.28:8081/repository/npm/
	npm config set sass_binary_site https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/node-sass
	npm config set phantomjs_cdnurl https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/phantomjs
	npm config set chromedriver_cdnurl https://devops.bt.siemens.com/artifactory/simple/libs-external/npmBinaries/chromedriver
fi
}

npminstall



