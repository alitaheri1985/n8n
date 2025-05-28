# Terraform vSphere VM Provisioning with Cloud-Init

This project provisions **virtual machines (VMs)** on a **VMware vSphere** environment using **Terraform** and **cloud-init**. Configuration is delivered via `vapp.properties` to support dynamic VM setup at boot time — no ISO needed.

---

## 📁 Project Structure

.
├── .gitignore # Ignores local state and Terraform cache files
├── .terraform.lock.hcl # Terraform dependency lock file
├── README.md # Project documentation
├── cloud-init.yml.tpl # Cloud-init template file
├── data.tf # Data sources (vSphere template, network, etc.)
├── main.tf # Main provisioning logic
├── outputs.tf # Terraform outputs
├── variables.tf # All input variables
├── terraform.tfvars # User-defined variable values
├── versions.tf # Provider and Terraform version constraints


---

## 🚀 Features

- Provision **multiple VMs** (masters and workers)
- Use **cloud-init** to configure each machine
- Assign **static IPs** and hostname automatically
- Inject **SSH keys** and hashed root password
- Full support for **vSphere vApp properties**
- Automatically attach to selected network/datastore/template
- Compatible with **Ubuntu cloud images**

---

## ☁️ What is Cloud-Init?

**Cloud-init** is the standard way to configure cloud VMs at boot time. It supports:

- Setting hostnames
- Creating users
- Installing SSH keys
- Configuring networking
- Updating packages
- Running commands at first boot

### 🔧 How It Works Here

- A `cloud-init.yml.tpl` template is rendered dynamically using `templatefile()`.
- Terraform injects real values (e.g., hostname, IP, SSH key) into it.
- The rendered file is **base64-encoded** and sent to the VM through `vapp.properties.user-data`.
- No need for ISO images or cloud drives. Cloud-init runs automatically at VM boot.

✅ **This makes provisioning fully automated.**

---

## 🧠 Example Rendered Cloud-Init

```yaml
#cloud-config
hostname: master-1
fqdn: master-1.local

users:
  - name: ahmad
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$rounds=4096$h...  # Hashed root password
    ssh_authorized_keys:
      - ssh-rsa AAAAB3... user@host
    ssh_pwauth: true

disable_root: false
ssh_pwauth: true

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
              - 192.168.10.10/24
            routes:
              - to: default
                via: 192.168.10.1
            nameservers:
              addresses: [8.8.8.8, 1.1.1.1]

runcmd:
  - sudo netplan apply

🔧 Configuration Variables (variables.tf)

All user-configurable settings live in variables.tf. Here's a quick overview:
🖥️ vSphere Connection
Variable	Description
vsphere_server	vCenter hostname or IP
vsphere_user	vSphere username
vsphere_password	vSphere password (sensitive)
vsphere_datacenter	Datacenter name
vsphere_host	ESXi host name or IP
vsphere_datastore	Datastore for VMs
vsphere_network	Network name
vm_template	Template name to clone
🧠 Master/Worker VM Config
Variable	Description	Default
master_vm_config	Count, CPU, RAM, disk, name prefix	3 x 2 vCPU, 4GB RAM
worker_vm_config	Count, CPU, RAM, disk, name prefix	3 x 4 vCPU, 8GB RAM
vm_guest_id	Guest OS type (usually ubuntu64Guest)	ubuntu64Guest
vm_folder	Optional VM folder in vCenter	""
vm_domain	Domain used for FQDN (e.g. local)	"local"
🌐 Network Settings
Variable	Description
vm_ipv4_gateway	Default gateway
vm_ipv4_netmask	Netmask in CIDR (e.g., 24)
vm_dns_servers	List of DNS servers
master_ips	Static IPs for master nodes
worker_ips	Static IPs for worker nodes
🔐 Access & Time
Variable	Description
vm_ssh_password	Hashed root password (openssl passwd)
vm_ssh_public_key_path	Path to public SSH key file
vm_ntp_server	NTP server address
⚙️ Usage

    Clone this repository

    Create and fill terraform.tfvars with your values

    Initialize and apply Terraform:

terraform init
terraform plan
terraform apply

📤 Outputs

Outputs include all VMs and their specifications:

all_vm_info = {
  masters = {
    "master-1" = {
      ip_address = "192.168.10.10"
      id         = "vm-101"
      cpu        = 2
      memory     = 4096
    }
  },
  workers = {
    "worker-1" = {
      ip_address = "192.168.10.20"
      id         = "vm-102"
      cpu        = 4
      memory     = 8192
    }
  }
}
