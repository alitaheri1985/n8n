#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}

users:
  - name: ${vm_user_name}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: ${root_password_hash}
    ssh_authorized_keys:
      - ${ssh_public_key}
    ssh_pwauth: true
    groups: users, admin
    home: /home/${vm_user_name}
disable_root: false
ssh_pwauth: true
ssh_authorized_keys: []

chpasswd:
  expire: false

package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - git
  - openssh-server
  - sshpass
  - jq
  - python3
write_files:
  - path: /etc/netplan/99-netcfg.yaml
    permissions: "0600"
    content: |
      network:
        version: 2
        ethernets:
          ens192:
            dhcp4: false
            dhcp6: false
            addresses:
              - ${ip_address}/${netmask}
            routes:
            - to: default
              via: ${gateway}
            nameservers:
              addresses: [${dns_servers}]
              
  - path: /home/${vm_user_name}/.ssh/id_ed25519
    permissions: "0400"
    content: |
      ${indent(6, ssh_private_key)}
  - path: /home/${vm_user_name}/.ssh/id_ed25519.pub
    permissions: "0400"
    content: |
      ${indent(6, ssh_public_key)}


    
%{ if hostname == "k8s-master-1" }
  - path: /opt/ansible/inventory.ini
    permissions: '0644'
    content: |
      [kube_control_plane]
%{ for index, addr in masters_info.ip_list ~}
      ${masters_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=ubuntu etcd_member_name=etcd${index + 1} ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp
%{ endfor ~}

      [etcd:children]
      kube_control_plane

      [kube_node]
%{ for index, addr in workers_info.ip_list ~}
      ${workers_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp
%{ endfor ~}
%{ endif }

runcmd:
  - sudo netplan apply
  - sudo apt update
  - sudo chown -R ${vm_user_name}:${vm_user_name} /home/ubuntu/
  - sudo mkdir  /home/${vm_user_name}/.ansible/
  - sudo mkdir  /home/${vm_user_name}/.ansible/tmp
  - sudo chmod 755 /home/${vm_user_name}/.ansible
  - sudo chmod 755 /home/${vm_user_name}/.ansible/tmp
  - sudo chown -R ${vm_user_name}:${vm_user_name} /home/${vm_user_name}/.ansible/tmp
  - sudo systemctl restart sshd
  - sudo chmod 400 /home/${vm_user_name}/.ssh/id_ed25519 /home/${vm_user_name}/.ssh/id_ed25519.pub
  - sudo apt -y install software-properties-common

%{ if hostname == "k8s-master-1" }
  - sudo apt update
  - sudo systemctl restart sshd
  - sudo apt install python3-pip git -y
  - sudo apt install python3-apt -y 
  - sudo add-apt-repository -y ppa:ansible/ansible --timeout 60
  - sudo pip3 install ansible-core==2.16.4 --break-system-packages --timeout 60
  - sudo chown -R ${vm_user_name}:${vm_user_name} /opt/ansible
  - sudo chmod 400 /home/${vm_user_name}/.ssh/id_ed25519 /home/${vm_user_name}/.ssh/id_ed25519.pub
  - git clone https://github.com/kubernetes-sigs/kubespray.git /opt/ansible/kubespray
  - cd /opt/ansible/kubespray
  - sudo pip3 install -r requirements.txt --break-system-packages --timeout 60
  - sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/ansible/inventory.ini cluster.yml --become -vvv  --become-user=root >> /home/ubuntu/log.txt 2>&1
%{ endif }
