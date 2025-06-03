locals {
  cloud_init_masters = [
    for idx in range(var.master_vm_config.count) : templatefile("${path.module}/cloud-init.yml.tpl", {
      root_password_hash = var.vm_ssh_password
      hostname           = "${var.master_vm_config.name}-${idx + 1}"
      vm_user_name       = var.vm_user_name
      domain             = var.vm_domain
      ip_address         = var.master_ips[idx]
      gateway            = var.vm_ipv4_gateway
      netmask            = var.vm_ipv4_netmask
      dns_servers        = join(", ", var.vm_dns_servers)
      ssh_key            = file(var.vm_ssh_public_key_path)
    })
  ]

  cloud_init_workers = [
    for idx in range(var.worker_vm_config.count) : templatefile("${path.module}/cloud-init.yml.tpl", {
      root_password_hash = var.vm_ssh_password
      hostname           = "${var.worker_vm_config.name}-${idx + 1}"
      vm_user_name       = var.vm_user_name
      domain             = var.vm_domain
      ip_address         = var.worker_ips[idx]
      gateway            = var.vm_ipv4_gateway
      netmask            = var.vm_ipv4_netmask
      dns_servers        = join(", ", var.vm_dns_servers)
      ssh_key            = file(var.vm_ssh_public_key_path)
      ssh-public-key     = var.ssh-public-key
    })
  ]
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine" "master" {
  count            = var.master_vm_config.count
  name             = "${var.master_vm_config.name}-${count.index + 1}"
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus  = var.master_vm_config.cpu
  memory    = var.master_vm_config.memory
  guest_id  = var.vm_guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

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
      user-data = base64encode(local.cloud_init_masters[count.index])
    }
  }

  # Wait for the VM to be ready
  wait_for_guest_net_timeout = 300
}

# Worker VMs
resource "vsphere_virtual_machine" "worker" {
  count            = var.worker_vm_config.count
  name             = "${var.worker_vm_config.name}-${count.index + 1}"
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus  = var.worker_vm_config.cpu
  memory    = var.worker_vm_config.memory
  guest_id  = var.vm_guest_id
  firmware  = data.vsphere_virtual_machine.template.firmware
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

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
      user-data = base64encode(local.cloud_init_workers[count.index])
    }
  }

  # Wait for the VM to be ready
  wait_for_guest_net_timeout = 300
}
