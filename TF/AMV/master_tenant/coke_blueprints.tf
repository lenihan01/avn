data "hpe_morpheus_blueprint" "ubuntu" {
  name        = "Ubuntu"
  provider    = hpe.master-tenant
}
