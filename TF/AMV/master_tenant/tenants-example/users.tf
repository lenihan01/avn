###############################################################################
# Tenant users
#
# Sub-tenant users require role_ids, but a multitenant master role's id cannot
# be assigned directly through the hpe_morpheus_user resource: Morpheus swaps in
# the sub-tenant's LOCAL copy of the role at apply time, which breaks the
# provider's post-apply consistency check ("planned ... does not correlate with
# any element in actual"). This is a provider bug (the resource echoes back the
# local role id for a Required field).
#
# Two mechanisms are used here:
#
#  1. Bootstrap admin (one per tenant): the FIRST user of a sub-tenant can't use
#     the workaround below (the sub-tenant provider that resolves local role ids
#     has to authenticate AS this admin -- chicken-and-egg). Instead it is
#     created straight through the Morpheus API by a local-exec provisioner,
#     which is not subject to Terraform's consistency check. See
#     bootstrap_admin.sh. Requires `curl` and `jq` on the machine running
#     Terraform.
#
#  2. Standard users: created by the master provider, but assigned the
#     tenant-LOCAL role id resolved by a hpe_morpheus_role data source scoped to
#     the sub-tenant (authenticated as the bootstrap admin), so planned ==
#     actual and no workaround is needed.
###############################################################################

# --- Bootstrap admin, one per tenant --------------------------------------
# Creates each tenant's bootstrap admin via the Morpheus API. The provisioner
# runs once when the resource is created and re-runs only if the tenant, admin
# username, or admin role changes (triggers_replace). The script is idempotent,
# so re-runs (or an admin left behind by an earlier failed apply) are no-ops.
#
# NOTE: this is create-only -- there is no destroy-time cleanup. On
# `terraform destroy` the users are removed automatically when their tenant
# (hpe_morpheus_tenant.this) is deleted.
resource "terraform_data" "admin" {
  for_each = local.tenants

  triggers_replace = {
    tenant_id = hpe_morpheus_tenant.this[each.key].id
    username  = local.admin_creds[each.key].username
    role_id   = hpe_morpheus_role.tenant_admin.id
  }

  provisioner "local-exec" {
    command = "bash \"${path.module}/bootstrap_admin.sh\""
    environment = {
      MORPH_URL      = var.morpheus_url
      MORPH_USER     = var.morpheus_username
      MORPH_PASS     = var.morpheus_password
      MORPH_INSECURE = tostring(var.morpheus_insecure)
      TENANT_ID      = tostring(hpe_morpheus_tenant.this[each.key].id)
      ADMIN_USER     = local.admin_creds[each.key].username
      ADMIN_EMAIL    = "${local.admin_creds[each.key].username}@example.com"
      ADMIN_PASS     = local.admin_creds[each.key].password
      ROLE_ID        = tostring(hpe_morpheus_role.tenant_admin.id)
    }
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
  name     = hpe_morpheus_role.tenant_user.name

  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_user,
    hpe_morpheus_tenant.this,
  ]
}

data "hpe_morpheus_role" "pepsi_user_role" {
  provider = hpe.pepsi
  name     = hpe_morpheus_role.tenant_user.name

  depends_on = [
    terraform_data.admin,
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
