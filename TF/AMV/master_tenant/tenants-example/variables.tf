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
  description = "Username of the bootstrap administrator created in the Coke tenant. The Coke sub-tenant provider authenticates as this user."
}

variable "coke_admin_password" {
  type        = string
  description = "Password for the Coke tenant bootstrap administrator."
  sensitive   = true
}

variable "pepsi_admin_username" {
  type        = string
  description = "Username of the bootstrap administrator created in the Pepsi tenant. The Pepsi sub-tenant provider authenticates as this user."
}

variable "pepsi_admin_password" {
  type        = string
  description = "Password for the Pepsi tenant bootstrap administrator."
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
