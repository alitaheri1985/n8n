# ☁️ Terraform vSphere Ubuntu Provisioning

This project uses **Terraform** to automate the provisioning of an **Ubuntu 24.04 virtual machine** on a **VMware vSphere/vCenter** infrastructure.  
CI/CD pipeline is integrated using **GitHub Actions** to ensure safe, repeatable, and automated infrastructure deployment.

---

## 📦 Features

- Deploys a VM from an existing Ubuntu 24.04 template
- Configurable VM name, network, and hardware
- CI/CD via GitHub Actions
- Secure credential management via GitHub Secrets
- Follows infrastructure-as-code best practices

---

## 🗂️ Project Structure

terraform-vsphere-ubuntu
```
├── main.tf # VM creation logic
├── provider.tf # vSphere provider config
├── variables.tf # Input variables
├── terraform.tfvars # Default variable values
└── .github/
       └─-- workflows/
               └──  terraform-vsphere.yml # CI/CD workflow
```
---

## 🔧 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- Access to a vSphere/vCenter environment
- An existing Ubuntu 24.04 VM template in your vCenter
- GitHub repository with configured secrets (see below)

---

## 🔐 GitHub Secrets Configuration

Go to your repo → **Settings > Secrets and Variables > Actions** → **New repository secret**, and add the following:

| Secret Name                | Description                           |
|---------------------------|---------------------------------------|
| `VSPHERE_USER`            | vSphere username                      |
| `VSPHERE_PASSWORD`        | vSphere password                      |
| `VSPHERE_SERVER`          | vCenter server address (without https)|
| `VSPHERE_DATACENTER`      | Name of the vSphere datacenter        |
| `VSPHERE_DATASTORE`       | Datastore to store the VM             |
| `VSPHERE_NETWORK`         | Network name (e.g., "VM Network")     |
| `VSPHERE_RESOURCE_POOL`   | Resource pool or cluster name         |
| `VSPHERE_TEMPLATE_NAME`   | Name of the Ubuntu 24.04 template     |
| ------------------------------------------------------------------|
---

## 🚀 Usage

### 🧪 Local Testing

```bash
terraform init
terraform validate
terraform plan
terraform apply



⚙️ GitHub Actions (CI/CD)

The included workflow (.github/workflows/terraform-vsphere.yml) runs automatically on:

    Every push to the main branch

    Pull requests (validation only)

It will:

    Initialize and validate Terraform

    Show the execution plan

    Automatically apply the changes (only on main branch)

🧹 Destroy VM (Manually)

To delete the created VM:

terraform destroy

