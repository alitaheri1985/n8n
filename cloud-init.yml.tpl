#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}

users:
  - name: ${vm_user_name}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: ${root_password_hash}
    ssh_authorized_keys:
      - ${ssh_public_key}
    ssh_pwauth: true

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
    permissions: "0644"
    content: |
      ${indent(6, ssh_private_key)}
  - path: /home/${vm_user_name}/.ssh/id_ed25519.pub
    permissions: "0644"
    content: |
      ${indent(6, ssh_public_key)}
runcmd:
  - sudo netplan apply
  - systemctl restart sshd
