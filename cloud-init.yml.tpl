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
disable_root: true #TODO  #DONE
ssh_pwauth: true

disable_root: true 
ssh_pwauth: true
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

  - path: /home/${vm_user_name}/script1.sh
    permissions: '0755'
    content: |
      ${indent(6, script)}
      
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
#TODO: add condition for these two files #DONE
%{ if hostname == "k8s-master-1" }
  - path: /home/${vm_user_name}/.ssh/id_ed25519
    permissions: "0400"
    content: |
      ${indent(6, ssh_private_key)}  
  - path: /home/${vm_user_name}/.ssh/id_ed25519.pub
    permissions: "0400"
    content: |
      ${indent(6, ssh_public_key)}
%{ endif }
%{ if hostname == "k8s-master-1" }
  - path: /opt/ansible/inventory.ini
    permissions: '0644'
    content: |
      [kube_control_plane]
%{ for index, addr in masters_info.ip_list ~}
      ${masters_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=ubuntu etcd_member_name=etcd${index + 1} ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp kubeconfig_localhost=true
%{ endfor ~}

      [etcd:children]
      kube_control_plane

      [kube_node]
%{ for index, addr in workers_info.ip_list ~}
      ${workers_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp
%{ endfor ~}
%{ endif }

#TODO: just run simple scripts DONE
#TODO: write two scripts for installing clusters DONE

runcmd:
- sudo netplan apply
- sudo sed -i "s/vm_user_name/ubuntu/g" /home/${vm_user_name}/script1.sh
- sudo /home/${vm_user_name}/script1.sh
- sudo ./script1.sh > /home/${vm_user_name}/script1.log 2>&1