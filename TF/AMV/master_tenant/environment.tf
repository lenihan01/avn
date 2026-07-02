variable "master_tenant_username" {
  type        = string
  description = "Master Tenant username"
}

variable "master_tenant_password" {
  type        = string
  description = "Master Tenant password"
}

variable "master_tenant_url" {
  type        = string
  description = "Master Tenant URL"
}
 
# Per-tenant variables

variable "coke_admin_password" {
  type        = string
  description = "Coke Admin Password"
}

variable "coke_password" {
  type        = string
  description = "Coke Password"
}

variable "coke_cloud_password" {
  type        = string
  description = "Coke VMWare Cloud 1 password"
}

