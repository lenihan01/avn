data "hpe_morpheus_instance_type" "ubuntu" {
  name        = "Ubuntu"
  provider    = hpe.master-tenant
}


resource "hpe_morpheus_instance_type" "wordpress_ubuntu" {
  name               = "Wordpress Ubuntu"
  code               = "wordpress_ubuntu"
  description        = "Wordpress Ubuntu Instance Toype"
  labels             = ["coke", "instance", "terraform", "wordpress"]
  category           = "web"
  visibility         = "private"
  featured           = false
  enable_deployments = true
  enable_scaling     = true
  enable_settings    = true
  environment_prefix = "TFEXAMPLE_DEMO"
  provider = hpe.coke-master-tenant

  evar {
    name   = "first"
    value  = "first"
    export = true
  }

  evar {
    name         = "second"
    masked_value = "second"
    export       = false
  }
}
