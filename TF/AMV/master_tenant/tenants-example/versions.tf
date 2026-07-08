terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.5.0"
    }
  }
}
