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

# EXPERIMENTAL: attempt to create "Coke-Finance" using the COKE tenant's
# provider (hpe.coke, authenticated as the Coke bootstrap admin) rather than the
# master provider.
#
# CAVEAT -- Morpheus tenancy is flat: every tenant is a child of the MASTER
# tenant, and the account model has no parent id (only a `master` boolean). So
# even issued through the coke provider this cannot produce a tenant that is
# nested under Coke. Expect one of two outcomes at apply time:
#   1. The API rejects tenant creation from a sub-tenant context (HTTP 403, even
#      though the Coke admin holds the admin-accounts "Tenants" feature), or
#   2. It succeeds, but Coke-Finance is simply another sibling sub-tenant of the
#      master -- not a child of Coke.
#
# depends_on defers the create until the Coke bootstrap admin (users.tf) exists,
# so the hpe.coke provider can authenticate.
resource "hpe_morpheus_tenant" "coke_finance" {
  provider = hpe.coke

  name         = "Coke-Finance"
  description  = "Attempted sub-tenant of Coke (Morpheus tenancy is flat -- see note in tenants.tf)"
  subdomain    = "coke-finance"
  enabled      = true
  base_role_id = hpe_morpheus_role.base.id
  currency     = "USD"

  depends_on = [terraform_data.admin]
}
