data "hpe_morpheus_instance_type_layout" "hvm" {
  name                        = "Single HVM"
  provider                    = hpe.master-tenant
}
