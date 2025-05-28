# Terraform vSphere VM Provisioning with Cloud-Init

This project provisions **virtual machines (VMs)** in a **VMware vSphere** environment using **Terraform** and **cloud-init**. Configuration is dynamically delivered through `vapp.properties` at boot time - no ISO required.

---

## 📁 Project Structure
```
.
├── .gitignore # Temporary files like state and cache
├── .terraform.lock.hcl # Terraform dependency lock file
├── README.md # Project documentation
├── cloud-init.yml.tpl # Cloud-init template
├── data.tf # Data sources (template, network, etc.)
├── main.tf # Main provisioning logic
├── outputs.tf # Terraform outputs
├── variables.tf # Input variables
├── terraform.tfvars # User-defined variable values
├── versions.tf # Terraform version constraints
```

---

## 🚀 Key Features

- Provision **multiple VMs** (master and worker nodes)
- Use **cloud-init** for automatic configuration
- Assign **static IPs** and hostnames automatically
- Inject **SSH keys** and hashed root password
- Full support for **vSphere vApp properties**
- Automatic connection to selected network/datastore/template
- Compatible with **Ubuntu Cloud Images**

---

## ☁️ What is Cloud-Init?

**Cloud-init** is the standard for configuring virtual machines at boot time. Capabilities include:

- Setting hostnames
- Creating users
- Installing SSH keys
- Network configuration
- Package updates
- Running commands at first boot

### 🔧 How It Works in This Project

1. The `cloud-init.yml.tpl` file is dynamically rendered using `templatefile()`
2. Terraform injects actual values (hostname, IP, SSH key)
3. The final file is **base64-encoded** and sent to the VM via `vapp.properties.user-data`
4. Cloud-init runs automatically at VM boot without ISO or cloud drive

✅ **This makes provisioning fully automated**

---

## 🧠 Example Cloud-Init Output

```

#cloud-config
hostname: master-1
fqdn: master-1.local

users:
  - name: ahmad
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$rounds=4096$h...  # Hashed password
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

```

##🔧 Configuration Variables (variables.tf)

All customizable settings are in variables.tf:
##🖥️ vSphere Connection
Variable	Description
vsphere_server	vCenter address
vsphere_user	vSphere username
vsphere_password	vSphere password (sensitive)
vsphere_datacenter	Datacenter name
vsphere_host	ESXi hostname/IP
vsphere_datastore	VM datastore
vsphere_network	Network name
vm_template	Template name
##🧠 VM Configuration
Variable	Description	Default
master_vm_config	Count, CPU, RAM, disk, name prefix	3x (2 vCPU, 4GB RAM)
worker_vm_config	Count, CPU, RAM, disk, name prefix	3x (4 vCPU, 8GB RAM)
vm_guest_id	OS type (usually ubuntu64Guest)	ubuntu64Guest
vm_folder	VM folder in vCenter (optional)	""
vm_domain	Domain for FQDN (e.g., local)	"local"
##🌐 Network Settings
Variable	Description
vm_ipv4_gateway	Default gateway
vm_ipv4_netmask	Network mask (CIDR e.g., 24)
vm_dns_servers	List of DNS servers
master_ips	Static IPs for master nodes
worker_ips	Static IPs for worker nodes
##🔐 Access & Time
Variable	Description
vm_ssh_password	Hashed password (openssl passwd)
vm_ssh_public_key_path	Path to SSH public key file
vm_ntp_server	NTP server address
##⚙️ Usage

    Clone the repository:
    bash

```

git clone https://github.com/your-repo/vsphere-terraform-cloudinit.git
cd vsphere-terraform-cloudinit

```
Create terraform.tfvars with your values:
hcl

vsphere_server = "vcenter.example.com"
vsphere_user = "admin@vsphere.local"
vsphere_password = "YourSecurePassword"
# ... other variables

Run Terraform:
bash

    terraform init    # Initialize
    terraform plan    # Preview changes
    terraform apply   # Apply configuration

📤 Outputs

After execution, the following information is displayed:
json

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

📝 Important Notes

    Always use a Ubuntu Cloud Image template that supports cloud-init

    Generate hashed passwords using:
    bash

openssl passwd -6 "YourPassword"

Do NOT commit terraform.tfvars to version control (included in .gitignore)

Modify cloud-init.yml.tpl to change cloud-init configuration

Ensure network interface names (e.g., ens192) match your template
