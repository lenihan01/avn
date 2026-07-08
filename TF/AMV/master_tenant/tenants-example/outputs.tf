output "tenant_ids" {
  description = "Map of tenant key => Morpheus tenant id."
  value       = { for k, t in hpe_morpheus_tenant.this : k => t.id }
}

output "tenant_base_role_ids" {
  description = "Map of tenant key => base (account) role id."
  value       = { for k, r in hpe_morpheus_role.tenant_base : k => r.id }
}

output "tenant_user_role_ids" {
  description = "Map of tenant key => standard user role id (master copy)."
  value       = { for k, r in hpe_morpheus_role.tenant_user : k => r.id }
}

output "tenant_admin_role_ids" {
  description = "Map of tenant key => admin role id (master copy). Morpheus assigns the tenant-local copy to the Terraform-managed bootstrap admin."
  value       = { for k, r in hpe_morpheus_role.tenant_admin : k => r.id }
}

output "tenant_admin_usernames" {
  description = "Map of tenant key => bootstrap admin username (created via the Morpheus API in users.tf)."
  value       = { for k, v in local.admin_creds : k => v.username }
}

output "coke_user_ids" {
  description = "Ids of the generated Coke tenant users (coke_user[*])."
  value       = hpe_morpheus_user.coke_user[*].id
}

output "pepsi_user_ids" {
  description = "Ids of the generated Pepsi tenant users (pepsi_user[*])."
  value       = hpe_morpheus_user.pepsi_user[*].id
}

output "tenant_group_ids" {
  description = "Map of tenant key => infrastructure group id (created inside each sub-tenant)."
  value       = local.tenant_group_ids
}

output "tenant_cloud_ids" {
  description = "Map of tenant key => VMware cloud id."
  value       = { for k, c in hpe_morpheus_cloud.vmware : k => c.id }
}

output "tenant_expiration_policy_ids" {
  description = "Map of tenant key => fixed-expiration lifecycle policy id (scoped to each tenant's group)."
  value = {
    coke  = hpe_morpheus_policy.coke_expiration.id
    pepsi = hpe_morpheus_policy.pepsi_expiration.id
  }
}

output "coke_ansible_integration_id" {
  description = "Id of the Coke tenant's Ansible integration (created inside the Coke sub-tenant)."
  value       = hpe_morpheus_integration_ansible.coke.id
}

output "coke_shell_task_id" {
  description = "Id of the Coke tenant's shell-script task (runs hostname; created inside the Coke sub-tenant)."
  value       = hpe_morpheus_task_shell_script.coke.id
}

output "pepsi_shell_task_id" {
  description = "Id of the Pepsi tenant's shell-script task (runs hostname; created inside the Pepsi sub-tenant)."
  value       = hpe_morpheus_task_shell_script.pepsi.id
}

output "coke_ansible_task_id" {
  description = "Id of the Coke tenant's Ansible playbook task (scoped to the Coke Ansible integration)."
  value       = hpe_morpheus_task_ansible_playbook.coke.id
}

output "coke_provisioning_workflow_id" {
  description = "Id of the Coke tenant's provisioning workflow (runs the Coke Ansible playbook at the provision phase)."
  value       = hpe_morpheus_workflow_provisioning.coke.id
}

output "coke_instance_type_id" {
  description = "Id of the Coke tenant's instance type (coke ubuntu wordpress)."
  value       = hpe_morpheus_instance_type.coke_ubuntu_wordpress.id
}
