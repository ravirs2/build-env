#!/bin/sh

### . /etc/os-release

sudo su -
_isubuntu= false
_iscentOS= false

_sshkeyfile="/root/.ssh/id_rsa"

_agent1ip="52.247.205.126"
_agent1uname="ubuntu"

verify_masteros () {

	if [ -n "$(uname -a | grep Ubuntu)" ]; then 
		echo "OS found in master server is ubuntu"
		_isubuntu true
	else 
		echo "OS found in master server is CentOS"
		_iscentOS= true
	fi 

}


 install_k3supprereq () {
	if [ _iscentOS ]; then
		echo "installing k3sup pre-reqs for centOS"
		sudo su - 
		sudo yum install -y container-selinux selinux-policy-base
		sudo rpm -i https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm
		
		echo "k3sup pre-reqs for centOS is installed --- SUCCESS"
	else 
		echo "pre-req available to install k3sup"
	fi
 
 }

verify_sshkey_avail () {
    
	_changeuser=$(sudo su -)
	_mycurdir=$(pwd)	
	echo "my current directory in master server is $_mycurdir   --- RIGHT PATH"
    cd /root
    if [ ! -f $_sshkeyfile ]; then
	   echo "SSH key is not available in master node server. Please upload it into /root/.ssh/   --- FAIL "
	   exit
    else 
	   echo "SSH key is available in master server to connect agent servers  --- SUCCESS"
	   
	fi
 
 }
 
 
verify_sshconnect_agent () {

    _agent1status=$(ssh -i id_rsa $_agent1uname@$_agent1ip exit | echo $?)
 
    if  [ $_agent1status -eq 0 ]; then
    	echo "K3s master server can SSH with Agent 1 server --- SUCCESS "
		exit
    else 
		echo "Check agent1 server details and security/firewall rules to allow connectivity  --- FAIL"
    fi
	

 } 


   
 {
 echo "changing sudo to root"
 sudo su - 
 verify_masteros 
 install_k3supprereq
 verify_sshkey_avail 
 verify_sshconnect_agent
 
 }

