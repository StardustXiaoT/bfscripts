#! /bin/sh
# Start VirtualBox @boot 
# /etc/init.d/startvm
#

#Edit these variables!
VMUSER=bf
VMNAME=BF_CI_Ubuntu
VMNAME2=BF_Centos
VMNAME3=BF_Ubuntu_Desktop
VMNAME4=BF_WIN7

case "$1" in
  start)
    echo "Starting VirtualBox VM ..."
    sudo -u $VMUSER nohup VBoxHeadless --startvm $VMNAME &
    sleep 3;
    sudo -u $VMUSER nohup VBoxHeadless --startvm $VMNAME2 &
    sleep 3;
    sudo -u $VMUSER nohup VBoxHeadless --startvm $VMNAME3 &
    sleep 3;
    sudo -u $VMUSER nohup VBoxHeadless --startvm $VMNAME4 &
    ;;
  stop)
    echo "Saving state of Virtualbox VM ..."
    sudo -u $VMUSER VBoxManage controlvm $VMNAME savestate
    sleep 3;
    sudo -u $VMUSER VBoxManage controlvm $VMNAME2 savestate
    sleep 3;
    sudo -u $VMUSER VBoxManage controlvm $VMNAME3 savestate
    sleep 3;
    sudo -u $VMUSER VBoxManage controlvm $VMNAME4 savestate
    ;;
  *)
    echo "Usage: /etc/init.d/StartVM {start|stop}"
    exit 1
    ;;
esac

exit 0
