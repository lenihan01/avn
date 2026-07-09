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

# Tenants created through the COKE tenant's provider (hpe.coke, authenticated as
# the Coke bootstrap admin) rather than the master provider. Confirmed working:
# the Coke admin's admin-accounts ("Tenants") feature lets the sub-tenant
# provider create tenants via the Morpheus API. Add more entries to
# local.coke_subtenants (locals.tf) to create additional ones.
#
# CAVEAT -- Morpheus tenancy is flat: the account model has no parent id (only a
# `master` boolean), so these are NOT nested under Coke; they are created in the
# master's tenant space. base_role_id references the shared master-owned Base
# Role, which the create accepts.
#
# depends_on defers each create until the Coke bootstrap admin (users.tf) exists,
# so the hpe.coke provider can authenticate.
resource "hpe_morpheus_tenant" "coke_subtenant" {
  for_each = local.coke_subtenants
  provider = hpe.coke

  name         = each.value.name
  description  = each.value.description
  subdomain    = each.value.subdomain
  enabled      = true
  base_role_id = hpe_morpheus_role.base.id
  currency     = "USD"

  depends_on = [terraform_data.admin]
}

# Preserve the already-created Coke-Finance tenant across the refactor from a
# single resource to the for_each map above (no destroy/recreate).
moved {
  from = hpe_morpheus_tenant.coke_finance
  to   = hpe_morpheus_tenant.coke_subtenant["coke_finance"]
}
