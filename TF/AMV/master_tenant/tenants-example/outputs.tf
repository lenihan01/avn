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
