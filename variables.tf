# vSphere connection variables
variable "vsphere_server" {
  description = "vSphere server FQDN or IP"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "vsphere_host" {
  description = "vSphere ESXi host name or IP"
  type        = string
}

variable "vsphere_datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "vsphere_network" {
  description = "vSphere network name"
  type        = string
}

variable "vm_template" {
  description = "VM template name"
  type        = string
}

# VM configuration variables
variable "vm_folder" {
  description = "vSphere folder for VMs"
  type        = string
  default     = ""
}

variable "master_vm_config" {
  description = "Master VM configuration"
  type = object({
    count    = number
    name     = string
    cpu      = number
    memory   = number
    disk     = number
  })
  default = {
    count    = 3
    name     = "k8s-master"
    cpu      = 2
    memory   = 4096
    disk     = 50
  }
}

variable "worker_vm_config" {
  description = "Worker VM configuration"
  type = object({
    count    = number
    name     = string
    cpu      = number
    memory   = number
    disk     = number
  })
  default = {
    count    = 3
    name     = "k8s-worker"
    cpu      = 4
    memory   = 8192
    disk     = 100
  }
}

variable "vm_domain" {
  description = "Domain name for VMs"
  type        = string
  default     = "local"
}

variable "vm_guest_id" {
  description = "Guest OS ID"
  type        = string
  default     = "ubuntu64Guest"
}

# Network configuration
variable "vm_ipv4_gateway" {
  description = "IPv4 gateway for VMs"
  type        = string
}

variable "vm_ipv4_netmask" {
  description = "IPv4 netmask (CIDR notation, e.g., 24)"
  type        = number
  default     = 24
}

variable "vm_dns_servers" {
  description = "DNS servers for VMs"
  type        = list(string)
}

variable "master_ips" {
  description = "Static IP addresses for master nodes"
  type        = list(string)
}

variable "worker_ips" {
  description = "Static IP addresses for worker nodes"
  type        = list(string)
}

variable "vm_ssh_password" {
  description = "SSH password for root user"
  type        = string
}

variable "vm_ntp_server" {
  description = "NTP server address"
  type        = string
  default     = "time.google.com"
}
