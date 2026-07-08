###############################################################################
# Per-tenant Ansible integration (Coke only)
#
# The Coke tenant gets an Ansible (git) integration. hpe_morpheus_integration_
# ansible has no tenant_id -- like a group (clouds.tf), the integration belongs
# to whichever tenant its provider is authenticated as. So it is created through
# the Coke sub-tenant provider (hpe.coke), which logs in as the bootstrap admin,
# and therefore lives inside the Coke tenant.
#
# The bootstrap admin needs the "integrations-ansible" feature permission to
# create it. That code is granted on the tenant_admin role AND raised in the
# tenant_base ceiling (both derive feature_permissions from
# local.tenant_ceiling_features in roles.tf) so it survives into the tenant-local
# admin copy. NOTE: "integrations-ansible" was newly ADDED to that ceiling for
# this integration, and raising the ceiling is NOT retroactive -- an already-
# deployed Coke tenant may need a destroy/apply (or a targeted replace of
# hpe_morpheus_tenant.this["coke"]) before the permission reaches the existing
# tenant-local admin copy. A fresh apply picks it up with no extra steps.
#
# Only the Coke tenant was requested, so -- unlike the group/cloud/policy which
# fan out over both tenants -- this is declared once, for Coke. depends_on defers
# creation until the bootstrap admin exists (for auth) and the roles carrying the
# permission have been applied.
#
# The repository is the public Morpheus sample (no credentials). Point
# var.coke_ansible_url at a private repo and add auth (username/password,
# access_token, or key_pair_id) to use your own.
###############################################################################

resource "hpe_morpheus_integration_ansible" "coke" {
  provider = hpe.coke

  name                          = "${local.tenants["coke"].name} Ansible"
  enabled                       = true
  url                           = var.coke_ansible_url
  default_branch                = var.coke_ansible_branch
  playbooks_path                = "/"
  roles_path                    = "roles"
  group_variables_path          = "group_vars"
  host_variables_path           = "/"
  enable_ansible_galaxy_install = true
  enable_verbose_logging        = true
  enable_agent_command_bus      = true
  enable_git_caching            = false

  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
  ]
}
