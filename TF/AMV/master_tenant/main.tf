terraform {
  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.5.0"
    }
  }
}

# Master Tenant
provider "hpe" {
  # Configuration options
  morpheus {
    username = var.master_tenant_username 
    password = var.master_tenant_password 
    url      = var.master_tenant_url 
    insecure = true

    alias = 'master'
  }
}

# Coke Master Tenant
provider "hpe" {
  # Configuration options
  morpheus {
    username = var.master_tenant_username
    password = var.master_tenant_password
    url      = var.master_tenant_url
    insecure = true

    alias = 'coke_master'
  }
}
