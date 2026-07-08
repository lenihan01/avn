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
  featured    = true
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
# node_type_ids references the VMware "Ubuntu 20.04" library node type by id, via
# var.coke_ubuntu_2004_node_type_id. It cannot be resolved by name: Morpheus
# ships one "Ubuntu 20.04" node type per technology (~17 of them), and the
# hpe_morpheus_node_type data source errors when a name matches more than one
# ("found 17 node types named Ubuntu 20.04") -- it only filters by name or id, not
# technology. So the specific VMware node type's id is supplied as a variable (see
# variables.tf for how to look it up). Creating the layout needs the
# "admin-containers" ("Library") feature permission, which is already in the
# ceiling (locals.tf) -- no extra permission is required.
###############################################################################

resource "hpe_morpheus_instance_type_layout" "coke_ubuntu_2004_layout" {
  provider = hpe.coke

  instance_type_id = hpe_morpheus_instance_type.coke_ubuntu_wordpress.id
  name             = "Coke Ubuntu 20.04 Layout"
  version          = "20.04"
  technology       = "vmware"
  creatable        = true
  labels           = ["coke", "terraform"]

  node_type_ids = [var.coke_ubuntu_2004_node_type_id]

  # Associate the Coke provisioning workflow (workflows.tf) with this layout, so
  # instances created from it run that workflow at provision. The layout already
  # sits after the workflow in the serialization chain (via the instance type),
  # so this reference adds no new ordering. (id is a string; Terraform converts it
  # to the number workflow_id expects, as with task_id/ansible_repo_id elsewhere.)
  workflow_id = hpe_morpheus_workflow_provisioning.coke.id

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
