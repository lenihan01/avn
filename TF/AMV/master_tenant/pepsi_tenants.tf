resource "hpe_morpheus_tenant" "pepsi-master-tenant" {
  name            = "Coke"
  description     = "Coke Master Tenant"
  enabled         = true
  subdomain       = "pepsi"
  base_role_id    = hpe_morpheus_role.pepsi_tenant_role.id
  currency        = "USD"
  account_number  = "12345"
  account_name    = "tenant 12345"
  customer_number = "12345"
  provider        = hpe.master-tenant
}
