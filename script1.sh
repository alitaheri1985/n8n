!#/bin/bash
# This script is used to configure the VM after it has been created.
sudo netplan apply
sudo chown -R ${vm_user_name}:${vm_user_name} /home/${vm_user_name}/ #TODO: set vm_user_name for ubuntu    DONE
sudo mkdir  /home/${vm_user_name}/.ansible/
sudo mkdir  /home/${vm_user_name}/.ansible/tmp
sudo chmod 755 /home/${vm_user_name}/.ansible
sudo chmod 755 /home/${vm_user_name}/.ansible/tmp
sudo chown -R ${vm_user_name}:${vm_user_name} /home/${vm_user_name}/.ansible/tmp
sudo systemctl restart sshd
sudo apt install software-properties-common -y #TODO: why it is needed to be installed in all vms

if [hostname == "k8s-master-1"];then
  sudo systemctl restart sshd
  sudo apt install python3-pip git -y
  sudo apt install python3-apt -y
  sudo add-apt-repository -y ppa:ansible/ansible --timeout 60
  sudo pip3 install ansible-core==2.16.4 --break-system-packages --timeout 60
  sudo chown -R ${vm_user_name}:${vm_user_name} /opt/ansible
  sudo chmod 400 /home/${vm_user_name}/.ssh/id_ed25519 /home/${vm_user_name}/.ssh/id_ed25519.pub
  git clone https://github.com/kubernetes-sigs/kubespray.git /opt/ansible/kubespray
  cd /opt/ansible/kubespray
  sudo pip3 install -r requirements.txt --break-system-packages --timeout 60
  sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/ansible/inventory.ini cluster.yml --become -vvv  --become-user=root >> /home/ubuntu/log.txt 2>&1 && export KUBECONFIG=/etc/kubernetes/admin.conf
fi