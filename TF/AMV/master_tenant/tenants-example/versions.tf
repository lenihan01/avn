terraform {
  # >= 1.11 is required for the write-only "password_wo" user attribute.
  required_version = ">= 1.11.0"

  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }
  }
}
