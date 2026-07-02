resource "hpe_morpheus_user" "coke_admin" {
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id
  username                    = "coke_admin"
  email                       = "coke_admin@testacc.com"
  password_wo                 = var.coke_admin_password 
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.coke_admin.id]
  first_name                  = "Coke"
  last_name                   = "Admin"
  linux_username              = "coke_admin"
  linux_password_wo           = var.coke_admin_password 
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "coke_admin"
  windows_password_wo         = var.coke_admin_password 
  windows_password_wo_version = 1
  provider                    = hpe.master-tenant
}

resource "hpe_morpheus_user" "coke" {
  count                       = 2
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id 
  username                    = "coke${count.index}"
  email                       = "coke${count.index}@testacc.com"
  password_wo                 = var.coke_password 
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.coke_user.id]
  first_name                  = "Coke"
  last_name                   = "User${count.index}"
  linux_username              = "coke${count.index}"
  linux_password_wo           = var.coke_password 
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "coke${count.index}"
  windows_password_wo         = var.coke_password 
  windows_password_wo_version = 1
  provider                    = hpe.master-tenant
}
