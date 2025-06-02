Terraform vSphere VM Provisioning with Cloud-Init

This project provisions **virtual machines (VMs)** in a **VMware vSphere** environment using **Terraform** and **cloud-init**. Configuration is dynamically delivered through vapp.properties at boot time - no ISO required.

⚠️ **Critical Warnings and Best Practices**  
- **Backup state files**: This file updates automatically. Deletion may disrupt infrastructure state  
- **Use remote state**: For team environments, implement remote state with locking  
- **Case sensitivity**: All Terraform files and references are case-sensitive  
- **Repository hygiene**: Keep provider versions updated in `versions.tf`  
- **Quoting requirements**: Wrap non-variable values in `" "`  

---

## 📁 Project Structure

```
├── .gitignore # Temporary files (state, cache)
├── .terraform.lock.hcl # Dependency lock file
├── README.md # Project documentation
├── cloud-init.yml.tpl # Cloud-init template
├── data.tf # Data sources
├── main.tf # Provisioning logic
├── outputs.tf # Output variables
├── variables.tf # Input variables
├── terraform.tfvars # User variables
├── versions.tf # Version constraints

```
##   Routing to connect vms

- To access master and worker together we need to implement routing befor deploying machines
also in the your company's router we should assign the vm's IP range that will create via terraform in router (for example mikrotik)
1. login to your router via winbox
2. go to IP > address and select new
3. add an ip address as vm's gateway in range of vm ip address
4. in the main.tf file set router ip address as ip4_gateway 

---

## 🚀 Key Features
- Provision **multiple VMs** (master/worker nodes)  
- **Cloud-init** auto-configuration  
- **Static IP** and hostname assignment  
- **SSH key** and password injection  
- Full **vApp properties** support  
- Compatible with **Ubuntu Cloud Images**  

---

## ☁️ Cloud-Init Operation
### 🔧 Workflow
1. `cloud-init.yml.tpl` rendered with `templatefile()`  
2. Actual values (IP, hostname, SSH keys) injected  
3. Rendered file **base64-encoded** to `vapp.properties.user-data`  
4. Cloud-init executes automatically at first boot  

✅ **Provisioning fully automated - no ISOs required**
- **Static IP conflicts**: When using static IPs, configure through cloud-init NOT vSphere customization
- 
---

## 🧠 Example Cloud-Init Config

```
#cloud-config
hostname: master-1
fqdn: master-1.local

users:
  - name: admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$... # Hashed password
    ssh_authorized_keys:
      - ssh-rsa AAAAB3Nza... 
    ssh_pwauth: true

disable_root: false

package_update: true
package_upgrade: true

write_files:
  - path: /etc/netplan/99-netcfg.yaml
    permissions: "0600"  # Critical permission
    content: |
      network:
        version: 2
        ethernets:
          ens192:        # Verify interface name!
            dhcp4: false
            addresses: [192.168.10.10/24]
            routes: [{ to: default, via: 192.168.10.1 }]
            nameservers: 
              addresses: [8.8.8.8, 1.1.1.1]
              
runcmd:
  - [sudo, netplan, apply]  # Apply network config

```
🔧 Configuration (variables.tf)

## 🖥️ vSphere Connection
Variable	Description
vsphere_server	vCenter FQDN/IP
vsphere_user	API username
vsphere_password	API password (sensitive)
vsphere_datacenter	Target datacenter
vsphere_host	ESXi host
vsphere_datastore	Storage destination
vsphere_network	Network name
vm_template	OVA template (unbooted)

## 🧠 VM Configuration
Variable	Description	Default
master_vm_config	Master nodes (count, CPU, RAM)	3x (2 vCPU, 4GB RAM)
worker_vm_config	Worker nodes (count, CPU, RAM)	3x (4 vCPU, 8GB RAM)
vm_guest_id	Guest OS type	ubuntu64Guest
vm_folder	vCenter VM folder (optional)	""
vm_domain	FQDN domain suffix	"local"

## 🌐 Network Settings
Variable	Description
vm_ipv4_gateway	Default gateway
vm_ipv4_netmask	Subnet mask (CIDR)
vm_dns_servers	DNS servers
master_ips	Master node static IPs
worker_ips	Worker node static IPs

## 🔐 Access & Time
Variable	Description
vm_ssh_password	Hashed root password
vm_ssh_public_key_path	SSH public key path
vm_ntp_server	NTP server address

## ⚙️ Usage
```
bash

git clone https://github.com/Intellare/intellare-infra
cd vsphere-terraform-cloudinit
```
# Create terraform.tfvars with your values
```
cat > terraform.tfvars <<EOF
vsphere_server = "vcenter.example.com"
vsphere_user = "admin@vsphere.local"
vsphere_password = "YourSecurePassword"
vm_template = "ubuntu-22.04-cloudimg"
master_ips = ["192.168.10.10", "192.168.10.11"]
worker_ips = ["192.168.10.20", "192.168.10.21"]
EOF
```

- **Secure sensitive values**: Store secrets in `terraform.tfvars` or GitHub Secrets - never commit them  
- **Protect state files**: Never share `.tfstate` files in public repositories 
- **Quoting requirements**: Wrap non-variable values in `" "`
- 
# Execute Terraform
```
terraform init
terraform plan
terraform apply
```
📤 Outputs
json
```
all_vm_info = {
  "masters" = {
    "master-1" = {
      cpu = 2
      id = "vm-123"
      ip_address = "192.168.10.10"
      memory = 4096
    }
  },
  "workers" = {
    "worker-1" = {
      cpu = 4
      id = "vm-124"
      ip_address = "192.168.10.20"
      memory = 8192
    }
  }
}

```
📝 Critical Implementation Notes
Template Requirements:
 * Use OVA templates that support cloud-init
 * Template must be never booted (to prevent IP conflicts)
 * Ubuntu cloud images recommended: ubuntu-22.04-cloudimg
 * Password Handling:
    bash
 # Generate hashed password
```
    openssl passwd -6 "YourSecurePassword"
```

Cloud-init Configuration:
 * Verify network interface names match your template
 * Netplan files are applied in numerical order (99 > 01)
 * Ensure correct file permissions (e.g., 0600 for netplan)
 * Test cloud-init configs with cloud-init validator
Security:
   Never commit terraform.tfvars or .tfstate files
   Use Terraform backends with encryption for state files
   Rotate credentials regularly
   Troubleshooting:
   Check VM console for cloud-init errors
   Examine /var/log/cloud-init.log on VMs
   Validate base64 decoding: base64 -d <<< YOUR_ENCODED_STRING
###
    Warning: Static IP assignment requires proper cloud-init configuration. Avoid mixing vSphere customization with cloud-init networking.
###

### Key additions:
2. Template preparation requirements (OVA format, never booted)
3. Case sensitivity warnings throughout
4. Permission requirements for cloud-init files
5. Netplan configuration priority note
6. Password generation command
7. Troubleshooting section with diagnostic commands
8. Static IP conflict warning
9. Security recommendations for state handling
10. Added note about interface name verification
11. Backup and state management warnings
12. Quoting requirements for non-variable values

## Variables

Define variables in `variables.tf` or a `.tfvars` file.

| Variable              | Description                           | Type           | Example Value                          |
|----------------------|---------------------------------------|----------------|----------------------------------------|
| vsphere_server       | vSphere server FQDN or IP             | string         | `vcenter.example.com`                  |
| vsphere_user         | vSphere username                      | string         | `administrator@vsphere.local`          |
| vsphere_password     | vSphere password (sensitive)          | string         | `your-password`                        |
| vsphere_datacenter   | vSphere datacenter name               | string         | `Datacenter`                           |
| vsphere_host         | vSphere ESXi host name or IP          | string         | `esxi01.example.com`                   |
| vsphere_datastore    | vSphere datastore name                | string         | `datastore1`                           |
| vsphere_network      | vSphere network name                  | string         | `VM Network`                           |
| vm_template          | VM template name                      | string         | `ubuntu-template`                      |
| vm_folder            | vSphere folder for VMs                | string         | `k8s-cluster`                          |
| vm_guest_id          | Guest OS ID                           | string         | `ubuntu64Guest`                        |
| vm_domain            | Domain name for VMs                   | string         | `example.com`                          |
| vm_ipv4_gateway      | IPv4 gateway for VMs                  | string         | `192.168.1.1`                          |
| vm_ipv4_netmask      | IPv4 netmask (CIDR)                   | number         | `24`                                   |
| vm_dns_servers       | List of DNS servers                   | list(string)   | `["8.8.8.8", "8.8.4.4"]`               |
| master_ips           | Static IPs for master nodes           | list(string)   | `["192.168.1.10", "192.168.1.11"]`     |
| worker_ips           | Static IPs for worker nodes           | list(string)   | `["192.168.1.12", "192.168.1.13"]`     |
| vm_ssh_password      | Hashed SSH password                   | string         | `$6$...`                               |
| vm_user_name         | VM user name                          | string         | `admin`                                |
| vm_ssh_public_key_path | Path to SSH public key              | string         | `~/.ssh/id_rsa.pub`                    |
| vm_ntp_server        | NTP server address                    | string         | `time.google.com`                      |
| master_vm_config     | Master VM config                      | object         | See below                              |
| worker_vm_config     | Worker VM config                      | object         | See below                              |

#### Example `master_vm_config` and `worker_vm_config`:

###
The warnings are integrated directly into relevant sections rather than at the end, ensuring users see critical information before implementation.
###
