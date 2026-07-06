data "hpe_morpheus_role" "coke_master" {
#  name = "Tenant Admin"
  id   = 2
  provider = hpe.master-tenant
}

data "hpe_morpheus_role" "coke_user" {
  name = "User Admin"
  provider = hpe.master-tenant
#  id   = 85
}

data "hpe_morpheus_role" "coke_admin" {
  name = "Tenant Admin"
  provider = hpe.master-tenant
  # id = 65
}


resource "hpe_morpheus_role" "coke_user_role" {
  # Seems to be necessary to depend on creation ot tenant!
  depends_on = [
   hpe_morpheus_tenant.coke-master-tenant
  ]
  name        = "Coke User Role"
  multitenant = false
  description = "Coke User Role"
  role_type   = "user"
  provider    = hpe.coke-master-tenant
  permissions = {
    default_group_access = "full"
    feature_permissions = [
      {
        access = "full",
        code   = "provisioning-state"
      },
      {
        access = "full",
        code   = "provisioning"
      }
    ]
  }
}
