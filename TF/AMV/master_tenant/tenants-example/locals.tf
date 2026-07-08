# Definition of the two tenants to create. Add another entry here to create
# more tenants -- roles, tenants and outputs all fan out from this map.
locals {
  tenants = {
    coke = {
      name        = "Coke"
      subdomain   = "coke"
      description = "Coke tenant"
    }
    pepsi = {
      name        = "Pepsi"
      subdomain   = "pepsi"
      description = "Pepsi tenant"
    }
  }
}

# Per-tenant bootstrap administrator credentials, keyed to match local.tenants.
# Mapping the sensitive admin variables here lets the admin user (users.tf) be
# driven with for_each instead of one hand-written block per tenant.
locals {
  admin_creds = {
    coke = {
      username = var.coke_admin_username
      password = var.coke_admin_password
    }
    pepsi = {
      username = var.pepsi_admin_username
      password = var.pepsi_admin_password
    }
  }
}
