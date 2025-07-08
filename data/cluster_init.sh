#!/bin/bash
set -Eeuo pipefail

sudo apt-get update -y && sudo apt-get upgrade -y
sudo netplan apply
sudo chown -R ubuntu:ubuntu /home/ubuntu/
sudo mkdir -p /home/ubuntu/.ansible/
sudo mkdir -p /home/ubuntu/.ansible/tmp
sudo chmod 755 /home/ubuntu/.ansible
sudo chmod 755 /home/ubuntu/.ansible/tmp
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ansible
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ansible/tmp
sudo systemctl restart ssh

if [ $HOSTNAME = "k8s-master-1" ]; then
  sudo apt update
  sudo apt install python3-pip git -y
  sudo apt install python3-apt -y
  sudo add-apt-repository -y ppa:ansible/ansible
  sudo apt install software-properties-common -y
  sudo pip3 install ansible-core==2.16.4 --break-system-packages --timeout 60
  sudo chown -R ubuntu:ubuntu /opt/ansible
  sudo chmod 400 /home/ubuntu/.ssh/id_ed25519 /home/ubuntu/.ssh/id_ed25519.pub
  git clone https://github.com/kubernetes-sigs/kubespray.git /opt/ansible/kubespray
  cd /opt/ansible/kubespray
  sudo pip3 install -r requirements.txt --break-system-packages --timeout 60
  sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/ansible/inventory.ini cluster.yml --become -vvv  --become-user=root >> /home/ubuntu/log.txt 2>&1
fi