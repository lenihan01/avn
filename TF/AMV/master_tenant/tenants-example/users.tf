###############################################################################
# Tenant users
#
# Sub-tenant users require role_ids, but a multitenant master role's id cannot
# be assigned directly: Morpheus swaps in the sub-tenant's LOCAL copy of the
# role at apply time, which breaks the provider's post-apply consistency check
# ("planned ... does not correlate with any element in actual").
#
# Two mechanisms sidestep that here:
#
#  1. Bootstrap admin (one per tenant, created by the master provider): its
#     role_ids reference a terraform_data helper whose `output` is UNKNOWN at
#     plan time, so whatever id Morpheus returns still satisfies the consistency
#     check. triggers_replace = [timestamp()] recreates the helper on every
#     apply, keeping output unknown even on re-applies (so a tainted admin can
#     always be recreated cleanly), and ignore_changes = [role_ids] stops later
#     plans from "correcting" the stored tenant-local id. Trade-off: the two
#     helper resources always show as "will be replaced" in the plan. (If you
#     prefer no perpetual diff, drop triggers_replace -- but then a failed admin
#     create must be cleared with `terraform state rm` before re-applying.)
#
#  2. Standard users: assigned the tenant-LOCAL role id resolved by a
#     hpe_morpheus_role data source scoped to the sub-tenant (authenticated as
#     the bootstrap admin), so planned == actual and no workaround is needed.
###############################################################################

# --- Bootstrap admin, one per tenant --------------------------------------

# Launders the (known) admin role id into an UNKNOWN-at-plan value: `output` is
# computed and only set at apply, and triggers_replace = [timestamp()] recreates
# this every apply so output is unknown on every plan -- including re-applies,
# which is what makes admin creation robust against the role_ids swap.
resource "terraform_data" "admin_role_ref" {
  for_each = local.tenants

  input            = hpe_morpheus_role.tenant_admin[each.key].id
  triggers_replace = [timestamp()]
}

# Created by the master provider (tenant_id targets the sub-tenant). The
# sub-tenant providers in providers.tf then authenticate as this user.
resource "hpe_morpheus_user" "admin" {
  for_each = local.tenants

  tenant_id           = hpe_morpheus_tenant.this[each.key].id
  username            = local.admin_creds[each.key].username
  email               = "${local.admin_creds[each.key].username}@example.com"
  password_wo         = local.admin_creds[each.key].password
  password_wo_version = 1
  first_name          = each.value.name
  last_name           = "Admin"
  role_ids            = [terraform_data.admin_role_ref[each.key].output]

  lifecycle {
    # Morpheus returns the tenant-local copy of the role id, not the master id
    # we sent; ignore it so subsequent plans don't try to "correct" it and
    # re-trigger the consistency error.
    ignore_changes = [role_ids]
  }
}

# --- Resolve each tenant's local user-role id -----------------------------
# Read through the sub-tenant providers (authenticated as the bootstrap admin)
# to get the tenant-LOCAL copy of the multitenant user role. Provider aliases
# can't be selected dynamically (no for_each over providers), so these are
# declared once per tenant. depends_on defers the read until the admin exists
# (for auth) and the multitenant role has been copied into the tenant.

data "hpe_morpheus_role" "coke_user_role" {
  provider = hpe.coke
  name     = hpe_morpheus_role.tenant_user["coke"].name

  depends_on = [
    hpe_morpheus_user.admin,
    hpe_morpheus_role.tenant_user,
    hpe_morpheus_tenant.this,
  ]
}

data "hpe_morpheus_role" "pepsi_user_role" {
  provider = hpe.pepsi
  name     = hpe_morpheus_role.tenant_user["pepsi"].name

  depends_on = [
    hpe_morpheus_user.admin,
    hpe_morpheus_role.tenant_user,
    hpe_morpheus_tenant.this,
  ]
}

# --- Standard users -------------------------------------------------------
# Created by the master provider (tenant_id targets the sub-tenant). role_ids
# uses the resolved tenant-local id, so planned == actual and no consistency
# error occurs. Adjust the counts with coke_user_count / pepsi_user_count.

resource "hpe_morpheus_user" "coke_user" {
  count = var.coke_user_count

  tenant_id           = hpe_morpheus_tenant.this["coke"].id
  username            = "coke_user${count.index}"
  email               = "coke_user${count.index}@example.com"
  password_wo         = var.user_password
  password_wo_version = 1
  first_name          = "Coke"
  last_name           = "User ${count.index}"
  role_ids            = [data.hpe_morpheus_role.coke_user_role.id]
}

resource "hpe_morpheus_user" "pepsi_user" {
  count = var.pepsi_user_count

  tenant_id           = hpe_morpheus_tenant.this["pepsi"].id
  username            = "pepsi_user${count.index}"
  email               = "pepsi_user${count.index}@example.com"
  password_wo         = var.user_password
  password_wo_version = 1
  first_name          = "Pepsi"
  last_name           = "User ${count.index}"
  role_ids            = [data.hpe_morpheus_role.pepsi_user_role.id]
}
