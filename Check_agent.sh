#!/bin/sh

### . /etc/os-release

sudo su -
_isubuntu= false
_iscentOS= false

_sshkeyfile="/root/.ssh/id_rsa"

_agent1ip="52.247.205.126"
_agent1uname="ubuntu"

verify_agentos () {

	if [ -n "$(uname -a | grep Ubuntu)" ]; then 
		echo "OS found in agent server is ubuntu"
		_isubuntu true
	else 
		echo "OS found in agent server is CentOS"
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

   
 {
 echo "changing sudo to root"
 sudo su - 
 verify_agentos 
 install_k3supprereq
 
 }

