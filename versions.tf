terraform {
  required_version = ">= 1.0"

  required_providers {
    vsphere = {
<<<<<<< HEAD
      source  = "vmware/vsphere" #TODO: change version of vsphare
      version = "~> 2.13.0"
=======
      source  = "vsphere/vsphere" #TODO: change version of vsphare
      version = "~> 2.12"
>>>>>>> 7c8a114 (edit my todo)
    }
  }
  cloud {

    organization = "Roshana"

    workspaces {
      name = "kube-infra"
    }
  }
}