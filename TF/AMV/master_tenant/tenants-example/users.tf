###############################################################################
# Tenant users
#
# Sub-tenant users require role_ids, but a multitenant master role's id cannot
# be assigned directly: Morpheus swaps in the sub-tenant's local copy of the
# role at apply time, which breaks the provider's post-apply consistency check
# ("planned ... does not correlate with any element in actual").
#
# This module resolves each tenant's LOCAL role id with a hpe_morpheus_role
# data source scoped to that sub-tenant, then assigns that id to the generated
# users -- so planned == actual and no error occurs.
#
# The data sources authenticate as each tenant's bootstrap admin, so an admin
# must exist first. The admin can't use the data source to find its own role
# (it would have to exist before it could authenticate), so its role is
# assigned with the terraform_data unknown-at-plan trick plus ignore_changes:
# an unknown set element passes the create-time consistency check, and
# ignore_changes stops later plans from re-introducing the mismatch.
###############################################################################

# --- Bootstrap admin, one per tenant --------------------------------------

# Makes role_ids unknown at plan time on create. An unknown set element
# satisfies the provider's consistency check, so the create is not rejected
# when Morpheus substitutes the tenant-local copy of the role id.
resource "terraform_data" "admin_role_ref" {
  for_each = local.tenants
  input    = hpe_morpheus_role.tenant_admin[each.key].id
}

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
    # Morpheus returns the tenant-local role id (not the master id we sent);
    # ignore it so subsequent plans don't try to "correct" it and re-trigger
    # the consistency error.
    ignore_changes = [role_ids]
  }
}

# --- Resolve each tenant's local user-role id -----------------------------
# Provider aliases can't be selected dynamically (no for_each over providers),
# so these are declared per tenant. depends_on defers the read until the admin
# exists (for auth) and the multitenant role has been copied into the tenant.

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
