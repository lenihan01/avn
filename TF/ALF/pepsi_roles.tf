data "hpe_morpheus_role" "pepsi_master" {
#  name = "Tenant Admin"
  id   = 2
}

data "hpe_morpheus_role" "pepsi_user" {
  name = "User Admin"
}
