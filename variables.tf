variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

variable "datacenter" {}
variable "datastore" {}
variable "network" {}
variable "resource_pool" {}
variable "template_name" {}
variable "host_name" {}
variable "vm_name" {
  default = "ubuntu-2404-tf"
}
variable "network_name" {
  description = "Name of the network to connect VM"
  type        = string
}
