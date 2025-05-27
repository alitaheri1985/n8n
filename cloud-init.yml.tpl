#cloud-config
users:
  - name: root
    lock_passwd: false
    passwd: ${root_password_hash}
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
ssh_pwauth: true
