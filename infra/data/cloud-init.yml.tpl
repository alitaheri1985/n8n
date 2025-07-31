#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}
users:
  - name: ${vm_user_name}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ${ssh_public_key}
    ssh_pwauth: true
    groups: users, admin
    home: /home/${vm_user_name}

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

  - path: /home/${vm_user_name}/cluster_init.sh
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
      ${masters_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=${vm_user_name} etcd_member_name=etcd${index + 1} ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp kubeconfig_localhost=true
%{ endfor ~}

      [etcd:children]
      kube_control_plane

      [kube_node]
%{ for index, addr in workers_info.ip_list ~}
      ${workers_info.prefix}-${index + 1} ansible_host=${addr} ansible_ssh_user=${vm_user_name} ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519 ansible_remote_tmp=/home/ubuntu/.ansible/tmp
%{ endfor ~}
%{ endif }


runcmd:
- sudo netplan apply
- sudo sed -i "s/vm_user_name/${vm_user_name}/g" /home/${vm_user_name}/cluster_init.sh
- sudo /home/${vm_user_name}/cluster_init.sh
- sudo ./cluster_init.sh > /home/${vm_user_name}/cluster_init.log 2>&1
