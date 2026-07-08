###############################################################################
# Per-tenant automation task
#
# Each tenant gets a simple shell-script task that runs `hostname`. Like a
# group (clouds.tf) or the Ansible integration (integrations.tf),
# hpe_morpheus_task_shell_script has no tenant_id -- the task belongs to whichever
# tenant its provider is authenticated as. So each is created through that
# tenant's sub-tenant provider (hpe.coke / hpe.pepsi), which logs in as the
# bootstrap admin, and therefore lives inside that tenant.
#
# The bootstrap admin needs the "tasks" ("Tasks") feature permission to create it:
# the provider POSTs to /api/tasks, whose save action requires tasks at "full"
# access -- verified in the Morpheus TasksController. That code is granted on the
# tenant_admin role AND raised in the tenant_base ceiling (both derive
# feature_permissions from local.tenant_ceiling_features in roles.tf) so it
# survives into the tenant-local admin copy. NOTE: "tasks" was newly ADDED to that
# ceiling, and raising the ceiling is NOT retroactive -- an already-deployed
# tenant must be recreated (destroy/apply) before the permission reaches the
# existing tenant-local admin copy. A fresh apply picks it up with no extra steps.
#
# Provider aliases cannot be selected via for_each, so -- like the group in
# clouds.tf -- each tenant's task is declared as its own resource block (one for
# Coke, one for Pepsi) rather than fanning out over local.tenants. depends_on
# defers creation until the bootstrap admin exists (for auth) and the roles
# carrying the permission have been applied.
#
# execute_target = "local" runs the script on the Morpheus appliance itself, so
# no target host/agent is required for this demonstration task.
###############################################################################

resource "hpe_morpheus_task_shell_script" "coke" {
  provider = hpe.coke

  name           = "${local.tenants["coke"].name} Hostname"
  code           = "coke_hostname"
  labels         = ["coke", "terraform"]
  source_type    = "local"
  script_content = "hostname\n"
  execute_target = "resource"
  result_type    = "value"
  sudo           = false
  retryable      = false

  # Serialize the Coke tenant's automation/library resources so they are POSTed
  # one at a time. Morpheus returns a 500 ("threw a gasket") when a tenant
  # receives several concurrent creates -- the losing create is still committed
  # server-side but reported to Terraform as an error (leaving it out of state).
  # The Coke tenant creates enough resources at once to trigger this, so they are
  # chained: integration -> shell task -> ansible task -> workflow -> instance
  # type. (Pepsi has far fewer concurrent creates and does not need the chain.)
  # depends_on also defers creation until the bootstrap admin exists (for auth)
  # and the permission-carrying roles have been applied.
  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
    hpe_morpheus_integration_ansible.coke,
  ]
}

resource "hpe_morpheus_task_shell_script" "pepsi" {
  provider = hpe.pepsi

  name           = "${local.tenants["pepsi"].name} Hostname"
  code           = "pepsi_hostname"
  labels         = ["pepsi", "terraform"]
  source_type    = "local"
  script_content = "hostname\n"
  execute_target = "resource"
  result_type    = "value"
  sudo           = false
  retryable      = false

  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
  ]
}

###############################################################################
# Coke Ansible playbook task
#
# Runs an Ansible playbook from the Coke tenant's own Ansible integration
# (integrations.tf). ansible_repo_id references that integration, so the task
# is scoped to the "Coke Ansible" repo (and the reference also defers creation
# until the integration exists). execute_target = "resource" runs the playbook
# against the provisioned resource/instance. Like the shell task it is created
# via the Coke sub-tenant provider and needs the "tasks" permission, which is
# already in the ceiling (locals.tf) -- no additional permission is required.
###############################################################################

resource "hpe_morpheus_task_ansible_playbook" "coke" {
  provider = hpe.coke

  name            = "${local.tenants["coke"].name} Ansible Playbook"
  code            = "coke_ansible_playbook"
  labels          = ["coke", "terraform"]
  ansible_repo_id = hpe_morpheus_integration_ansible.coke.id
  playbook        = "wordpress_ub.yml"
  execute_target  = "resource"
  retryable       = false

  # Next link in the Coke automation chain (integration -> shell task -> ansible
  # task -> workflow -> instance type): follows the shell task so the Coke
  # tenant's resources are created one at a time and avoid the concurrent-create
  # 500 Morpheus returns under several simultaneous same-tenant creates. (The
  # integration is already an implicit dependency via ansible_repo_id.)
  depends_on = [
    terraform_data.admin,
    hpe_morpheus_role.tenant_base,
    hpe_morpheus_role.tenant_admin,
    hpe_morpheus_task_shell_script.coke,
  ]
}
