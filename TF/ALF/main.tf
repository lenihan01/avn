terraform {
  required_providers {
    hpe = {
      source  = "HPE/hpe"
      version = "1.4.0"
    }
  }
}

provider "hpe" {
  # Configuration options
  morpheus {
    username = "john.lenihan@hpe.com"
    password = "<redacted>"
    url      = "https://360ubuntu1.hpelabs.local"
    insecure = true
  }
}
