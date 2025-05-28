#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}

users:
  - name: ahmad
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: ${root_password_hash}
    ssh_authorized_keys:
      - ${ssh_key}
    ssh_pwauth: true

disable_root: false
ssh_pwauth: true
ssh_authorized_keys: []

chpasswd:
  expire: false

package_update: true
package_upgrade: true

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
runcmd:
  - sudo netplan apply
