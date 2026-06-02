resource "hpe_morpheus_tenant" "pepsi-master-tenant" {
  name            = "Pepsi"
  description     = "Pepsi Master Tenant"
  enabled         = true
  subdomain       = "tfexample"
  base_role_id    = data.hpe_morpheus_role.pepsi_master.id
  currency        = "USD"
  account_number  = "23456"
  account_name    = "tenant 23456"
  customer_number = "23456"
}
