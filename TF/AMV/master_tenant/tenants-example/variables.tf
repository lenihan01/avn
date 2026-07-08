variable "morpheus_url" {
  type        = string
  description = "Base URL of the Morpheus appliance, e.g. https://morpheus.example.local"
}

variable "morpheus_username" {
  type        = string
  description = "Master tenant username used to authenticate to Morpheus."
}

variable "morpheus_password" {
  type        = string
  description = "Master tenant password used to authenticate to Morpheus."
  sensitive   = true
}

variable "morpheus_insecure" {
  type        = bool
  description = "Skip TLS certificate verification (useful for lab appliances with self-signed certs)."
  default     = false
}

variable "coke_admin_username" {
  type        = string
  description = "Username for the bootstrap administrator created via the Morpheus API in the Coke tenant (users.tf). The Coke sub-tenant provider authenticates as this user."
}

variable "coke_admin_password" {
  type        = string
  description = "Password for the Coke tenant bootstrap administrator (created via the Morpheus API in users.tf)."
  sensitive   = true
}

variable "pepsi_admin_username" {
  type        = string
  description = "Username for the bootstrap administrator created via the Morpheus API in the Pepsi tenant (users.tf). The Pepsi sub-tenant provider authenticates as this user."
}

variable "pepsi_admin_password" {
  type        = string
  description = "Password for the Pepsi tenant bootstrap administrator (created via the Morpheus API in users.tf)."
  sensitive   = true
}

variable "user_password" {
  type        = string
  description = "Password assigned to every generated tenant user (coke_user*/pepsi_user*). Use per-user secrets in production."
  sensitive   = true
}

variable "coke_user_count" {
  type        = number
  description = "Number of standard users to create in the Coke tenant (coke_user[0..n-1])."
  default     = 3
}

variable "pepsi_user_count" {
  type        = number
  description = "Number of standard users to create in the Pepsi tenant (pepsi_user[0..n-1])."
  default     = 5
}

# --- VMware (vCenter) cloud settings -----------------------------------------
# One infrastructure group and one VMware cloud are created per tenant
# (clouds.tf). These mirror the per-tenant cloud variables in the parent module
# (coke_clouds.tf/pepsi_clouds.tf).

# Coke VMware cloud
variable "coke_cloud_url" {
  type        = string
  description = "vCenter API URL for the Coke VMware cloud, e.g. https://vcenter.example.local"
}

variable "coke_cloud_datacenter" {
  type        = string
  description = "vCenter datacenter for the Coke VMware cloud."
}

variable "coke_cloud_cluster" {
  type        = string
  description = "vCenter cluster for the Coke VMware cloud."
}

variable "coke_cloud_username" {
  type        = string
  description = "vCenter username for the Coke VMware cloud."
  default     = "administrator@vsphere.local"
}

variable "coke_cloud_password" {
  type        = string
  description = "vCenter password for the Coke VMware cloud."
  sensitive   = true
}

# Pepsi VMware cloud
variable "pepsi_cloud_url" {
  type        = string
  description = "vCenter API URL for the Pepsi VMware cloud, e.g. https://vcenter.example.local"
}

variable "pepsi_cloud_datacenter" {
  type        = string
  description = "vCenter datacenter for the Pepsi VMware cloud."
}

variable "pepsi_cloud_cluster" {
  type        = string
  description = "vCenter cluster for the Pepsi VMware cloud."
}

variable "pepsi_cloud_username" {
  type        = string
  description = "vCenter username for the Pepsi VMware cloud."
  default     = "administrator@vsphere.local"
}

variable "pepsi_cloud_password" {
  type        = string
  description = "vCenter password for the Pepsi VMware cloud."
  sensitive   = true
}

# --- Ansible integration (Coke tenant) ---------------------------------------
# integrations.tf creates one Ansible (git) integration inside the Coke
# sub-tenant. Set coke_ansible_url to the git repository to attach (see
# terraform.tfvars.example); for a private repo also add auth on the resource.
variable "coke_ansible_url" {
  type        = string
  description = "Git repository URL for the Coke tenant's Ansible integration."
}

variable "coke_ansible_branch" {
  type        = string
  description = "Default branch of the Coke tenant's Ansible repository."
  default     = "master"
}
