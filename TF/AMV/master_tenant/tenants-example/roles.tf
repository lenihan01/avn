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
# hpe_morpheus_role data sources try to list roles.
#
# The tenant_admin and tenant_user roles below are multitenant: the master owns
# them and Morpheus propagates master-side edits down to each sub-tenant's copy
# automatically (a plain `terraform apply` suffices) -- unless the copy is masked
# by this ceiling. So we set a deliberately BROAD ceiling here
# (local.tenant_ceiling_features) covering the common tenant Administration
# features, so granting any of them to a tenant role later reaches the sub-tenant
# copy without recreating anything.
#
# Note the asymmetry: raising THIS ceiling (adding a code to the list) is applied
# only when roles are seeded into the tenant, so it is NOT retroactive -- an
# existing tenant must be recreated to pick up a newly added ceiling code (that
# is why enabling admin-zones on an already-deployed tenant needed a
# destroy/apply). Granting a permission that is ALREADY within the ceiling to a
# tenant role propagates with no recreate. Keeping the ceiling wide up front
# avoids future recreates.
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

    # Deliberately broad ceiling -- see local.tenant_ceiling_features and the
    # header comment. Granting any of these to a tenant role later propagates to
    # the sub-tenant copy without recreating the tenant.
    feature_permissions = [
      for code in local.tenant_ceiling_features : { code = code, access = "full" }
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

    # admin-health is granted to every role by request. It is also in the
    # base-role ceiling (local.tenant_ceiling_features), so this grant survives
    # into the multitenant role's sub-tenant copy. (tenant_base and tenant_admin
    # receive it via that ceiling list; this user role has no other feature
    # permissions, so it is listed explicitly here.)
    feature_permissions = [
      { code = "admin-health", access = "full" }
    ]
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

    # Grant the tenant admin the full ceiling (local.tenant_ceiling_features), so
    # it is a complete administrator over the tenant's Administration features --
    # reading roles for the sub-tenant data sources (users.tf), creating the
    # infrastructure group (clouds.tf), and managing clouds, servers, policies,
    # etc. Because this matches the base-role ceiling, every code survives into
    # the tenant-local copy.
    feature_permissions = [
      for code in local.tenant_ceiling_features : { code = code, access = "full" }
    ]
  }
}
