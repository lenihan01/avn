data "hpe_morpheus_role" "coke_master" {
#  name = "Tenant Admin"
  id   = 2
}

data "hpe_morpheus_role" "coke_user" {
  name = "User Admin"
}
