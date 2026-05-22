resource "hpe_morpheus_user" "coke" {
  count                       = 1
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id 
  username                    = "coke${count.index}"
  email                       = "coke${count.index}@testacc.com"
  password_wo                 = "Secret123!"
  password_wo_version         = 1
  role_ids                    = [1]
  first_name                  = "Coke"
  last_name                   = "User${count.index}"
  linux_username              = "linuser"
  linux_password_wo           = "Linux123!"
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "winuser"
  windows_password_wo         = "Windows123!"
  windows_password_wo_version = 1
}

resource "hpe_morpheus_user_group" "example" {
  name         = "tftest"
  description  = "terraform"
  sudo_access  = true
  server_group = "test"
  user_ids     = [hpe_morpheus_user.coke.id]
}
