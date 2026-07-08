# Base "tenant" role -- one per tenant. Every hpe_morpheus_tenant requires a
# base role (base_role_id); it defines the default account-level access granted
# to the tenant.
#
# IMPORTANT: the base (account) role also acts as the PERMISSION CEILING for the
# tenant. When a multitenant master role is copied into this tenant, the copy's
# permissions are masked down to whatever the base role grants. If the base role
# grants no feature permissions, every copied role has its feature permissions
# stripped -- e.g. the tenant_admin role's "admin-roles" permission is dropped
# from its tenant-local copy, so the tenant admin gets HTTP 403 when the
# hpe_morpheus_role data sources try to list roles. We therefore grant
# admin-roles here so that permission survives into the copied tenant_admin role.
# We likewise grant admin-groups so each tenant's bootstrap admin can create the
# per-tenant infrastructure group backing its VMware cloud (clouds.tf).
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

    # Raise the tenant's feature-permission ceiling so admin capabilities granted
    # to tenant roles (e.g. tenant_admin's admin-roles/admin-groups) are not
    # masked out of their tenant-local copies.
    feature_permissions = [
      { code = "admin-roles", access = "full" },
      { code = "admin-users", access = "full" },
      { code = "admin-groups", access = "full" },
    ]
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

# Tenant administrator role -- assigned to each tenant's bootstrap admin, which
# is created via the Morpheus API in users.tf (the user the sub-tenant providers
# authenticate as). It includes the "admin-roles" feature permission so the
# admin can read the tenant's roles for the data-source lookups in users.tf.
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

    # Lets the admin read roles for the sub-tenant role data sources (users.tf)
    # and create the per-tenant infrastructure group in clouds.tf.
    feature_permissions = [
      { code = "admin-roles", access = "full" },
      { code = "admin-groups", access = "full" },
    ]
  }
}
