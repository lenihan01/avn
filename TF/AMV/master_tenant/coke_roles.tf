resource "hpe_morpheus_role" "coke_tenant_role" {
  name        = "Coke Tenant Admin Role"
  description = "Coke Tenant Admin Role"
  role_type   = "tenant"
  provider    = hpe.master-tenant
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

resource "hpe_morpheus_role" "coke_user_role" {
  # Seems to be necessary to depend on creation ot tenant!
  depends_on = [
   hpe_morpheus_tenant.coke-master-tenant
  ]
  name        = "Coke User Role"
  multitenant = true 
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
