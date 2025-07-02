terraform {
  required_version = ">= 1.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere" #TODO: change version of vsphare
      version = "~> 2.13.0"
    }
  }
  cloud {

    organization = "Roshana"

    workspaces {
      name = "kube-infra"
    }
  }
}
