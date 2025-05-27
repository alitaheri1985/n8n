# Master VM outputs
output "master_vm_names" {
  description = "Names of master VMs"
  value       = vsphere_virtual_machine.master[*].name
}

output "master_vm_ips" {
  description = "IP addresses of master VMs"
  value       = vsphere_virtual_machine.master[*].default_ip_address
}

output "master_vm_ids" {
  description = "IDs of master VMs"
  value       = vsphere_virtual_machine.master[*].id
}

# Worker VM outputs
output "worker_vm_names" {
  description = "Names of worker VMs"
  value       = vsphere_virtual_machine.worker[*].name
}

output "worker_vm_ips" {
  description = "IP addresses of worker VMs"
  value       = vsphere_virtual_machine.worker[*].default_ip_address
}

output "worker_vm_ids" {
  description = "IDs of worker VMs"
  value       = vsphere_virtual_machine.worker[*].id
}

# Combined outputs for convenience
output "all_vm_info" {
  description = "All VM information"
  value = {
    masters = {
      for i, vm in vsphere_virtual_machine.master : vm.name => {
        ip_address = vm.default_ip_address
        id         = vm.id
        cpu        = vm.num_cpus
        memory     = vm.memory
      }
    }
    workers = {
      for i, vm in vsphere_virtual_machine.worker : vm.name => {
        ip_address = vm.default_ip_address
        id         = vm.id
        cpu        = vm.num_cpus
        memory     = vm.memory
      }
    }
  }
}

