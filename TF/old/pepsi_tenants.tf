resource "hpe_morpheus_tenant" "pepsi-master-tenant" {
  name            = "Pepsi"
  description     = "Pepsi Master Tenant"
  enabled         = true
  subdomain       = "pepsi"
  base_role_id    = hpe_morpheus_role.pepsi_tenant_role.id
  currency        = "EUR"
  account_number  = "23456"
  account_name    = "tenant 23456"
  customer_number = "23456"
  provider        = hpe.master-tenant
}
