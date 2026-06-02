resource "hpe_morpheus_user" "pepsi1" {
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id 
  username                    = "pepsi1"
  email                       = "pepsi1@testacc.com"
  password_wo                 = "Secret123!"
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.pepsi_user.id]
  first_name                  = "Pepsi"
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


resource "hpe_morpheus_user" "pepsi2" {
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id
  username                    = "pepsi2"
  email                       = "pepsi2@testacc.com"
  password_wo                 = "Secret123!"
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.pepsi_user.id]
  first_name                  = "Pepsi"
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
