terraform {
  required_version = ">= 1.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.14.0"
    }
  }
  cloud {

    organization = "Roshana"

    workspaces {
      name = "kube-infra"
    }
  }
}
