terraform {
  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.3.0"
    }
  }
}

provider "hpe" {
  # Configuration options
  morpheus {
    username = "username"
    password = "password"
    url      = "https://emorph.can.cs8.local"
}
