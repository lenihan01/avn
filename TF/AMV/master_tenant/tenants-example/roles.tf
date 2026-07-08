# Base "tenant" role -- one per tenant. Every hpe_morpheus_tenant requires a
# base role (base_role_id); it defines the default account-level access granted
# to the tenant.
resource "hpe_morpheus_role" "tenant_base" {
  for_each = local.tenants

  name        = "${each.value.name} Tenant Base Role"
  description = "Base account role for the ${each.value.name} tenant"
  role_type   = "tenant"

  # default_cloud_access is a tenant-scoped permission (default_group_access is
  # only valid on "user" roles).
  permissions = {
    default_cloud_access             = "full"
    default_instance_type_access     = "full"
    default_blueprint_access         = "full"
    default_catalog_item_type_access = "full"
    default_persona_access           = "full"
    default_report_type_access       = "full"
    default_task_access              = "full"
    default_vdi_pool_access          = "full"
    default_workflow_access          = "full"
  }
}

# Standard end-user role -- one per tenant. multitenant = true means the master
# tenant owns the role and Morpheus copies it into every sub-tenant, where it
# can be assigned to that tenant's users.
#
# NOTE: Do not assign a multitenant role's master id directly to a
# hpe_morpheus_user in a sub-tenant via Terraform. Morpheus substitutes the
# sub-tenant's local copy of the role (a different id) at apply time, and the
# provider currently fails with:
#   "Provider produced inconsistent result after apply: .role_ids".
# This example resolves the tenant-local copy with a hpe_morpheus_role data
# source scoped to each sub-tenant (see users.tf) and assigns that id.
resource "hpe_morpheus_role" "tenant_user" {
  for_each = local.tenants

  name        = "${each.value.name} User Role"
  description = "Standard user role for the ${each.value.name} tenant"
  role_type   = "user"
  multitenant = true

  # default_group_access is a user-scoped permission (default_cloud_access is
  # only valid on "tenant" roles).
  permissions = {
    default_group_access             = "read"
    default_instance_type_access     = "full"
    default_blueprint_access         = "none"
    default_catalog_item_type_access = "full"
    default_persona_access           = "full"
    default_report_type_access       = "none"
    default_task_access              = "full"
    default_vdi_pool_access          = "none"
    default_workflow_access          = "full"
  }
}

# Tenant administrator role -- assigned to each tenant's bootstrap admin user.
# Broad access so the sub-tenant provider (authenticating as this admin) can
# read the tenant's roles for the data-source lookups in users.tf.
#
# NOTE: depending on your Morpheus RBAC, reading roles may additionally require
# an explicit roles feature permission, e.g.:
#   permissions = { ...,
#     feature_permissions = [{ code = "admin-roles", access = "full" }] }
# Add it if the hpe_morpheus_role data source returns a permissions error.
resource "hpe_morpheus_role" "tenant_admin" {
  for_each = local.tenants

  name        = "${each.value.name} Admin Role"
  description = "Administrator role for the ${each.value.name} tenant"
  role_type   = "user"
  multitenant = true

  permissions = {
    default_group_access             = "full"
    default_instance_type_access     = "full"
    default_blueprint_access         = "full"
    default_catalog_item_type_access = "full"
    default_persona_access           = "full"
    default_report_type_access       = "full"
    default_task_access              = "full"
    default_vdi_pool_access          = "full"
    default_workflow_access          = "full"
  }
}
