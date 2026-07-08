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
