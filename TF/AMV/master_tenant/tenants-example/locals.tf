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

  # Bootstrap admin credentials per tenant. These users are created via the
  # Morpheus API in users.tf (local-exec); the sub-tenant providers
  # (providers.tf) then authenticate as them to resolve tenant-local roles.
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
