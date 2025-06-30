terraform {
  required_version = ">= 1.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere" #TODO: change version of vsphare
      version = "~> 2.12"
    }
  }
  cloud {

    organization = "Roshana"

    workspaces {
      name = "kube-infra"
    }
  }
}