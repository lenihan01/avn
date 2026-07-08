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

output "tenant_admin_user_ids" {
  description = "Map of tenant key => Terraform-managed bootstrap admin user id."
  value       = { for k, u in hpe_morpheus_user.admin : k => u.id }
}

output "coke_user_ids" {
  description = "Ids of the generated Coke tenant users (coke_user[*])."
  value       = hpe_morpheus_user.coke_user[*].id
}

output "pepsi_user_ids" {
  description = "Ids of the generated Pepsi tenant users (pepsi_user[*])."
  value       = hpe_morpheus_user.pepsi_user[*].id
}
