#!/bin/sh

. /etc/os-release
_isubuntu= false
_iscentOS= false

_sshkeypath="/home/script/id_rsa"
_masterscript="/home/script/"
_masterip="52.151.42.141"
_masteruname="ubuntu"

_agent1ip="52.247.205.126"
_agent1uname="ubuntu"

verify_os () {

case $ID in

        ubuntu)
                echo "Server OS is ubuntu"
                _isubuntu= true
                ;;
        centOS)
                echo "Server OS is centOS"
                _iscentOS= true
                ;;

 esac

 }

 install_k3sup () {
 
 if [ _isubuntu ] || [ _iscentOS ];
 then 
    sudo curl -sLS https://get.k3sup.dev | sh
	echo "k3sup installation is completed"
 fi
 
 
 
 }
 
 ssh_connect () {
	 echo "Checking SSH connectivity with master server"
	 ssh -i id_rsa $_masteruname@$_masterip 'sleep 2 &'
	 
 }



 verify_sshconnect_master () {
 
    if [ ! -f $_sshkeypath ]; then
	   echo "SSH key is not  found in the current directory"
	   exit
	else 
	   echo "SSH key is available to connect master & worker nodes servers --- SUCCESS"
	   
	fi
 
  _status=$(ssh -i id_rsa $_masteruname@$_masterip exit | echo $?)
   
  if  [ $_status -eq 0 ]; then
    	echo "K3s master server is connnected with ssh --- SUCCESS "
		
		
    else 
		echo "Check server details and security/firewall rules to allow connectivity  --- FAIL"
		exit
    fi
 
 } 
 
 
 verify_masternode () {
 
    if  [ $_status -eq 0 ]; then
		echo "Checking master node pre-reqs"
		cat "$_masterscript/Check_master.sh" | ssh -i id_rsa $_masteruname@$_masterip  
		### ssh -i id_rsa $_masteruname@$_masterip  "sudo su - $_masterscript/Check_master.sh"
		echo "Master node is ready with pre-reqs installed --- SUCCESS "
	else 
		echo "master node is not available with required pre-reqs"
	fi 
 }
     
 
  verify_agentnode () {
  
    _status=$(ssh -i id_rsa $_agent1uname@$_agent1ip exit | echo $?)
 
    if  [ $_status -eq 0 ]; then
		echo "Checking Agent node pre-reqs"
		cat "$_masterscript/Check_agent.sh" | ssh -i id_rsa $_agent1uname@$_agent1ip  
		
		echo "Agent node is ready with pre-reqs installed --- SUCCESS "
	else 
		echo "Agent node is not available with required pre-reqs"
	fi 
 }
   

 install_k3smaster (){
	 
	if verify_masternode; then
		echo "Installing K3s master server"
		export Master_IP=$_masterip
	 	k3sup install --ip $Master_IP --user $_masteruname --ssh-key $_sshkeypath
	 	echo "K3s master is installed successfully --- SUCCESS"
	fi

 }

 install_k3sagent () {
    if install_k3smaster; then 
		echo "Creating worker nodes & joining with server node"
		export Agent1_IP=$_agent1ip
		k3sup join --ip $Agent1_IP --server-ip $Master_IP --user $_agent1uname
		echo "K3s worker agent is joined successfully  --- SUCCESS"
	fi
 
 }
   
 {
 verify_os 
 install_k3sup
 verify_sshconnect_master
 verify_masternode
 install_k3smaster
 verify_agentnode
 install_k3sagent 
 }

