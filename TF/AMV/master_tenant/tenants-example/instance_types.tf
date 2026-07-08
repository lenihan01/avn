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

  # Tail of the Coke automation chain (integration -> shell task -> ansible task
  # -> workflow -> instance type): follows the workflow so the Coke tenant's
  # resources are created one at a time and avoid the concurrent-create 500
  # ("threw a gasket") Morpheus returns under several simultaneous same-tenant
  # creates.
  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
    hpe_morpheus_workflow_provisioning.coke,
  ]
}

###############################################################################
# Coke instance type layout
#
# Adds a VMware layout ("Coke Ubuntu 20.04 Layout", version 20.04) to the Coke
# tenant's "coke ubuntu wordpress" instance type (above). Like the instance type
# itself, hpe_morpheus_instance_type_layout has no tenant_id -- it belongs to
# whichever tenant its provider is authenticated as -- so it is created through
# the Coke sub-tenant provider (hpe.coke) and lives inside the Coke tenant.
#
# instance_type_id references the parent instance type, which both scopes the
# layout to it and defers creation until the instance type exists -- extending
# the Coke automation serialization chain by one link (... -> instance type ->
# layout), so the layout is POSTed after the instance type rather than
# concurrently, avoiding the concurrent-create 500 ("threw a gasket") Morpheus
# returns under simultaneous same-tenant creates.
#
# node_type_ids references the "Ubuntu 20.04" library node type, resolved by name
# through the Coke provider (the layout must reference a node type visible to the
# tenant). Creating the layout needs the "admin-containers" ("Library") feature
# permission, which is already in the ceiling (locals.tf) -- no extra permission
# is required.
###############################################################################

data "hpe_morpheus_node_type" "ubuntu_2004" {
  provider = hpe.coke

  name = "Ubuntu 20.04"

  # Read through the Coke sub-tenant provider (authenticated as the bootstrap
  # admin), so -- like the sub-tenant role lookups in users.tf -- defer the read
  # until the admin exists (for auth) and the tenant has been created. Without
  # this the data source is read at plan time, before the Coke admin exists, and
  # the hpe.coke provider cannot authenticate on the first apply.
  depends_on = [
    terraform_data.admin,
    hpe_morpheus_tenant.this,
  ]
}

resource "hpe_morpheus_instance_type_layout" "coke_ubuntu_2004_layout" {
  provider = hpe.coke

  instance_type_id = hpe_morpheus_instance_type.coke_ubuntu_wordpress.id
  name             = "Coke Ubuntu 20.04 Layout"
  version          = "20.04"
  technology       = "vmware"
  labels           = ["coke", "terraform"]

  node_type_ids = [data.hpe_morpheus_node_type.ubuntu_2004.id]

  # New tail of the Coke automation serialization chain: the instance_type_id
  # reference already defers this until the instance type exists; the explicit
  # role/admin dependencies mirror the other Coke sub-tenant resources (auth +
  # permission-carrying roles applied first).
  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
  ]
}
