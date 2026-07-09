# The Coke and Pepsi tenants. Both reference the shared "Base Role" via
# base_role_id. Created by the master tenant provider configured in providers.tf.
resource "hpe_morpheus_tenant" "this" {
  for_each = local.tenants

  name         = each.value.name
  description  = each.value.description
  subdomain    = each.value.subdomain
  enabled      = true
  base_role_id = hpe_morpheus_role.base.id
  currency     = "USD"
}
