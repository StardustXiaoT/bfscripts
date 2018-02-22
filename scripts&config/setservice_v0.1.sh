#!/bin/bash

#check if the script is running under root
if [ $EUID -ne 0 ]; then
	echo " This script must be run as root "
	exit 1
fi

# if [ -e /root/BF_Deploy ];then
	# echo "Please check BF_Deloy Version before continue"
	# exit 1
# else 
	# mkdir /root/BF_Deploy
# fi



PROJECTPATH=/root/BF_Deploy

#Copy Necessary File to Designated locatopm

function fileinstall(){
#copy there is a bug here
echo "Copying Packages to proper place"
arraywp=(wp3 wp2 wp4)
for servicename in ${arraywp[@]};
do
if [ -d $PROJECTPATH/$servicename ];then
	rm -rf $PROJECTPATH/$servicename
	cp -r  $servicename $PROJECTPATH/
else
	cp -r  $servicename $PROJECTPATH/
fi	
done

ls /opt|grep tomcat >/dev/null 2>&1
if [ $? -eq 0 ]; then
	cp -r $PROJECTPATH/wp4/www /opt/`ls /opt|grep tomcat`/webapps/
	echo "www setup 			[OK]"
	cp -r $PROJECTPATH/wp4/www/assets /opt/`ls /opt|grep tomcat`/webapps/ROOT
	echo "assets setup 			[OK]"
else 
	echo "Tomcat is not properly installed"
fi

if [ -e $PROJECTPATH/wp4/node_modules.tar.gz ] && [ ! -e $PROJECTPATH/wp4/node_modules ];then
	tar xvf $PROJECTPATH/wp4/node_modules.tar.gz -C $PROJECTPATH/wp4/
else 
	echo "Node modules not installed" 
	
fi
}

fileinstall

#Setup start initial scripts which startup all program as service 
 function setsystemservice(){
 echo "********Set system Service"
 arrayservice=(brownfield kafka adaptor uadaptor) #modeling 
 for servicename in ${arrayservice[@]};
 do 
	if [ -f `pwd`/systemservice/$servicename ];then
		chmod +x systemservice/$servicename
		cp `pwd`/systemservice/$servicename /etc/init.d/
		case "$servicename" in
			"adaptor" )
			sed -i "s#/root#$PROJECTPATH#g" /etc/init.d/$servicename 
			;;
			"uadaptor" )
			sed -i "s#/root#$PROJECTPATH#g" /etc/init.d/$servicename 
			;;
			"modeling" )
			sed -i "s#/root#$PROJECTPATH#g" /etc/init.d/$servicename 
			;;
		esac	

		chkconfig --add $servicename
		echo "Set System Service $servicename		[ok]"
	else
		echo "$servicename does not exist"
	fi
done


arraysystemd=(mongodb.service nodeserver.service)
echo "Install Systemd Service"
for service in ${arraysystemd[@]}
do
	echo "$systemdservice"
	if [ -f `pwd`/systemservice/$service ];then
		cp systemservice/$service /etc/systemd/system/
		case "$service" in
			"mongodb.service" )
			;;
			"nodeserver.service" )
			sed -i "s#/root#$PROJECTPATH#g" /etc/systemd/system/$service
			;;
		esac
		systemctl daemon-reload
		systemctl enable $service
		echo "$service configuratoin				[ok]"
		#systemctl $service start
	else
		echo "Setup $service Failed"
	fi
done
}

setsystemservice