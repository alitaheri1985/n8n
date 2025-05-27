locals {
  cloud_init_rendered = templatefile("${path.module}/cloud-init.yml.tpl", {
    root_password_hash = var.vm_ssh_password
    hostname           = "test"
    domain            = var.vm_domain

  })
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine" "master" {
  count               = var.master_vm_config.count
  name                = "${var.master_vm_config.name}-${count.index + 1}"
  resource_pool_id    = data.vsphere_host.host.resource_pool_id
  datastore_id        = data.vsphere_datastore.datastore.id
  folder              = var.vm_folder
  
  num_cpus         = var.master_vm_config.cpu
  memory           = var.master_vm_config.memory
  guest_id         = var.vm_guest_id
  firmware         = data.vsphere_virtual_machine.template.firmware
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  
  # Enable CPU and memory hot-add
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  
  disk {
    label            = "disk0"
    size             = var.master_vm_config.disk
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  cdrom {
    client_device = true
  }
    
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      user-data = base64encode(local.cloud_init_rendered)
    }
  }

  # Wait for the VM to be ready
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}

# Worker VMs
resource "vsphere_virtual_machine" "worker" {
  count               = var.worker_vm_config.count
  name                = "${var.worker_vm_config.name}-${count.index + 1}"
  resource_pool_id    = data.vsphere_host.host.resource_pool_id
  datastore_id        = data.vsphere_datastore.datastore.id
  folder              = var.vm_folder
  
  num_cpus         = var.worker_vm_config.cpu
  memory           = var.worker_vm_config.memory
  guest_id         = var.vm_guest_id
  firmware         = data.vsphere_virtual_machine.template.firmware
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  
  # Enable CPU and memory hot-add
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  cdrom {
    client_device = true
  }

  disk {
    label            = "disk0"
    size             = var.worker_vm_config.disk
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      "password" = "123"
      user-data = base64encode(local.cloud_init_rendered)
    }
  }

  # Wait for the VM to be ready
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}
