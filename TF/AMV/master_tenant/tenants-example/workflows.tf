###############################################################################
# Per-tenant provisioning workflow (Coke only)
#
# The Coke tenant gets a provisioning workflow that runs the Coke Ansible
# playbook task (tasks.tf) at the "provision" phase. Like a group, integration
# or task, hpe_morpheus_workflow_provisioning has no tenant_id -- the workflow
# belongs to whichever tenant its provider is authenticated as, so it is created
# through the Coke sub-tenant provider (hpe.coke) and lives inside the Coke
# tenant.
#
# The bootstrap admin needs the "workflows" ("Workflows") feature permission to
# create it: the provider POSTs to /api/task-sets, whose save action requires
# workflows at "full" access -- verified in the Morpheus TaskSetsController. That
# code is granted on the tenant_admin role AND raised in the tenant_base ceiling
# (both derive feature_permissions from local.tenant_ceiling_features in
# roles.tf) so it survives into the tenant-local admin copy. NOTE: "workflows"
# was newly ADDED to that ceiling, and raising the ceiling is NOT retroactive --
# an already-deployed Coke tenant must be recreated (destroy/apply) before the
# permission reaches the existing tenant-local admin copy. A fresh apply picks it
# up with no extra steps.
#
# The task block's task_id references the Coke Ansible playbook task, so the
# reference also defers creation until that task exists. Only the Coke tenant was
# requested, so this is declared once, for Coke.
###############################################################################

resource "hpe_morpheus_workflow_provisioning" "coke" {
  provider = hpe.coke

  name        = "${local.tenants["coke"].name} Provisioning Workflow"
  description = "Runs the ${local.tenants["coke"].name} Ansible playbook at the provision phase."
  labels      = ["coke", "terraform"]
  platform    = "all"
  visibility  = "private"

  task {
    task_id    = hpe_morpheus_task_ansible_playbook.coke.id
    task_phase = "provision"
  }

  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
  ]
}
