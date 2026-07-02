data "hpe_morpheus_role" "coke_master" {
#  name = "Tenant Admin"
  id   = 2
  provider = hpe.master-tenant
}

data "hpe_morpheus_role" "coke_user" {
  name = "User_Role"
  provider = hpe.master-tenant
#  id   = 85
}

data "hpe_morpheus_role" "coke_admin" {
  name = "Admin_Role_All_Tenants"
  provider = hpe.master-tenant
  # id = 65
}
