terraform {
  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.5.0"
    }
  }
}

provider "hpe" {
  # Configuration options
  morpheus {
    username = var.master_tenant_username 
    password = var.master_tenant_password 
    url      = var.master_tenant_url 
    insecure = true
  }
}
