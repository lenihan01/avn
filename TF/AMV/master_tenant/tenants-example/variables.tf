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
