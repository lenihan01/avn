data "hpe_morpheus_role" "coke_master" {
#  name = "Tenant Admin"
  id   = 2
}

data "hpe_morpheus_role" "coke_user" {
  name = "User_Role"
#  id   = 85
}

data @hpe_morpheus_role" "coke_admin" {
  name = "Admin_Role_All_Tenants"
  # id = 65
}
