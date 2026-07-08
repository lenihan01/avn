###############################################################################
# Per-tenant instance type (Coke only)
#
# The Coke tenant gets a library instance type ("coke ubuntu wordpress"). Like a
# group, integration, task or workflow, hpe_morpheus_instance_type has no
# tenant_id -- the instance type belongs to whichever tenant its provider is
# authenticated as, so it is created through the Coke sub-tenant provider
# (hpe.coke) and lives inside the Coke tenant.
#
# The bootstrap admin needs the "admin-containers" ("Library") feature permission
# to create it: the provider POSTs to /api/library/instance-types, whose save
# action requires admin-containers at "full" access -- verified in the Morpheus
# LibraryInstanceTypesController. That code is granted on the tenant_admin role
# AND raised in the tenant_base ceiling (both derive feature_permissions from
# local.tenant_ceiling_features in roles.tf) so it survives into the tenant-local
# admin copy. NOTE: "admin-containers" was newly ADDED to that ceiling, and
# raising the ceiling is NOT retroactive -- an already-deployed Coke tenant must
# be recreated (destroy/apply) before the permission reaches the existing
# tenant-local admin copy. A fresh apply picks it up with no extra steps.
#
# That endpoint is also gated by the "library" appliance LICENSE feature (not a
# role permission); if the appliance is not licensed for Library the create fails
# with a license error rather than a 403.
#
# Only the Coke tenant was requested, so this is declared once, for Coke.
###############################################################################

resource "hpe_morpheus_instance_type" "coke_ubuntu_wordpress" {
  provider = hpe.coke

  name        = "coke ubuntu wordpress"
  code        = "coke_ubuntu_wordpress"
  description = "Ubuntu WordPress instance type for the ${local.tenants["coke"].name} tenant."
  category    = "web"
  visibility  = "private"
  labels      = ["coke", "terraform"]

  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
  ]
}
