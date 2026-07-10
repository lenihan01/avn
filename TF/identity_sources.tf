###############################################################################
# Coke tenant identity source (Active Directory)
#
# Adds an Active Directory identity source to the Coke tenant so its users can
# authenticate against an AD domain. Unlike a group/task/integration (which have
# no tenant_id and belong to whichever tenant their provider is authenticated
# as), hpe_morpheus_identity_source_active_directory takes an explicit tenant_id,
# so -- like hpe_morpheus_cloud (clouds.tf) -- it is created by the MASTER (default
# hpe) provider with tenant_id targeting the Coke sub-tenant.
#
# default_account_role_id is the role assigned to an AD user on first login when
# no group mapping applies. It is wired to the Coke tenant-LOCAL copy of the
# multitenant "tenant_user" role (data.hpe_morpheus_role.coke_user_role in
# users.tf); referencing that data source also defers this resource until the
# Coke bootstrap admin exists and the role has been seeded into the tenant.
#
# Gated by var.create_coke_identity_source (default false) so a deployment
# without AD details still applies cleanly. Set that to true and supply the
# coke_ad_* variables (see variables.tf / terraform.tfvars.example) to create it.
# The AD connection fields (server, domain, binding username/password) are
# REQUIRED by the provider, so they must be non-empty when the toggle is on.
###############################################################################

resource "hpe_morpheus_identity_source_active_directory" "coke" {
  count = var.create_coke_identity_source ? 1 : 0

  tenant_id = hpe_morpheus_tenant.this["coke"].id
  name      = var.coke_ad_name

  ad_server = var.coke_ad_server
  domain    = var.coke_ad_domain

  binding_username = var.coke_ad_binding_username
  binding_password = var.coke_ad_binding_password

  use_ssl = var.coke_ad_use_ssl

  # Optional AD group gate: when set, only members of this group may log in, and
  # search_member_groups controls whether nested groups are included. Omitted
  # (null) when the variable is empty so Morpheus applies no group restriction.
  required_group       = var.coke_ad_required_group != "" ? var.coke_ad_required_group : null
  search_member_groups = var.coke_ad_search_member_groups

  description = var.coke_ad_description

  # Default role for AD users with no group mapping: the Coke tenant-local
  # "tenant_user" role (read via the Coke provider in users.tf).
  default_account_role_id = data.hpe_morpheus_role.coke_user_role.id
}
