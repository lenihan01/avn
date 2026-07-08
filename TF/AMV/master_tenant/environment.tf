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
# Coke
variable "coke_admin_username" {
  type        = string
  description = "Coke Admin Username"
}

variable "coke_admin_password" {
  type        = string
  description = "Coke Admin Password"
}

variable "coke_password" {
  type        = string
  description = "Coke Password"
}

# Cloud 1
variable "coke_cloud_password" {
  type        = string
  description = "Coke VMWare Cloud 1 password"
}

variable "coke_cloud_1_url" {
  type        = string
  description = "Coke Cloud 1 URL"
}

variable "coke_cloud_1_dc" {
  type        = string
  description = "Coke Cloud 1 Datacenter"
}

variable "coke_cloud_1_cluster" {
  type        = string
  description = "Coke Cloud 1 Cluster"
}

variable "coke_ubuntu_2404_node_type" {
  type        = number 
  description = "Coke Ubuntu 24.04 VMWare Node Type ID"
  default     = 365
}

# Pepsi
variable "pepsi_admin_username" {
  type        = string
  description = "Pepsi Admin Username"
}

variable "pepsi_admin_password" {
  type        = string
  description = "Pepsi Admin Password"
}

variable "pepsi_password" {
  type        = string
  description = "Prpsi Password"
}

# Cloud 1
variable "pepsi_cloud_password" {
  type        = string
  description = "pepsi VMWare Cloud 1 password"
}

variable "pepsi_cloud_1_url" {
  type        = string
  description = "Pepsi Cloud 1 URL"
}

variable "pepsi_cloud_1_dc" {
  type        = string
  description = "Pepsi Cloud 1 Datacenter"
}

variable "pepsi_cloud_1_cluster" {
  type        = string
  description = "Pepsi Cloud 1 Cluster"
}
