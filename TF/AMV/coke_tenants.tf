resource "hpe_morpheus_tenant" "coke-master-tenant" {
  name            = "Coke"
  description     = "Coke Master Tenant"
  enabled         = true
  subdomain       = "tfexample"
  base_role_id    = data.hpe_morpheus_role.coke_master.id
  currency        = "USD"
  account_number  = "12345"
  account_name    = "tenant 12345"
  customer_number = "12345"
}



data "hpe_morpheus_role" "coke_master" {
#  name = "Tenant Admin"
  id   = 2
}

data "hpe_morpheus_role" "coke_user" {
#  name = "User_Role"
  id   = 254 
}

