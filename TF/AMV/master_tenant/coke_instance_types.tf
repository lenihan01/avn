data "hpe_morpheus_instance_type" "ubuntu" {
  name        = "Ubuntu"
  provider    = hpe.master-tenant
}
