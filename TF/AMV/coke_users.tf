resource "hpe_morpheus_user" "coke1" {
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id 
  username                    = "coke1"
  email                       = "coke1@testacc.com"
  password_wo                 = "Secret123!"
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.coke_user.id]
  first_name                  = "Coke"
  last_name                   = "User1"
  linux_username              = "linuser"
  linux_password_wo           = "Linux123!"
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "winuser"
  windows_password_wo         = "Windows123!"
  windows_password_wo_version = 1
}


resource "hpe_morpheus_user" "coke2" {
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id
  username                    = "coke2"
  email                       = "coke2@testacc.com"
  password_wo                 = "Secret123!"
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.coke_user.id]
  first_name                  = "Coke"
  last_name                   = "User2"
  linux_username              = "linuser"
  linux_password_wo           = "Linux123!"
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "winuser"
  windows_password_wo         = "Windows123!"
  windows_password_wo_version = 1
}
