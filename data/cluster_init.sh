#!/bin/bash
set -Eeuo pipefail

sudo apt-get update -y && sudo apt-get upgrade -y
sudo netplan apply
sudo chown -R vm_user_name:vm_user_name /home/vm_user_name/
sudo mkdir -p /home/vm_user_name/.ansible/
sudo mkdir -p /home/vm_user_name/.ansible/tmp
sudo chmod 755 /home/vm_user_name/.ansible
sudo chmod 755 /home/vm_user_name/.ansible/tmp
sudo chown -R vm_user_name:vm_user_name /home/vm_user_name/.ansible
sudo chown -R vm_user_name:vm_user_name /home/vm_user_name/.ansible/tmp
sudo systemctl restart ssh

if [ $HOSTNAME = "k8s-master-1" ]; then
  sudo apt update
  sudo apt install python3-pip git -y
  sudo apt install python3-apt -y
  sudo add-apt-repository -y ppa:ansible/ansible
  sudo apt install software-properties-common -y
  sudo pip3 install ansible-core==2.16.4 --break-system-packages --timeout 60
  sudo chown -R vm_user_name:vm_user_name /opt/ansible
  sudo chmod 400 /home/vm_user_name/.ssh/id_ed25519 /home/vm_user_name/.ssh/id_ed25519.pub
  git clone https://github.com/kubernetes-sigs/kubespray.git /opt/ansible/kubespray
  cd /opt/ansible/kubespray
  sudo pip3 install -r requirements.txt --break-system-packages --timeout 60
  sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/ansible/inventory.ini cluster.yml --become -vvv  --become-user=root >> /home/ubuntu/log.txt 2>&1
fi