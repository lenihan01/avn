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
  alias = "master-tenant"
  # Configuration options
  morpheus {
    username = var.master_tenant_username 
    password = var.master_tenant_password 
    url      = var.master_tenant_url 
    insecure = true
  }
}

# Coke Master Tenant
provider "hpe" {
  alias = "coke-master-tenant"
  # Configuration options
  morpheus {
    username = var.coke_admin_username
    password = var.coke_admin_password
    url      = var.master_tenant_url
    insecure = true
    tenant_subdomain = "coke"
  }
}

# Pepsi Master Tenant
provider "hpe" {
  alias = "pepsi-master-tenant"
  # Configuration options
  morpheus {
    username = var.pepsi_admin_username
    password = var.pepsi_admin_password
    url      = var.master_tenant_url
    insecure = true
    tenant_subdomain = "pepsi"
  }
}
