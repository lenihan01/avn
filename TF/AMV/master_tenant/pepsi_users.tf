resource "hpe_morpheus_user" "pepsi_admin" {
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id
  username                    = var.pepsi_admin_username
  email                       = "${var.pepsi_admin_username}@testacc.com"
  password_wo                 = var.pepsi_admin_password
  password_wo_version         = 1
  role_ids                    = [hpe_morpheus_role.pepsi_admin_role.id]
  first_name                  = "Pepsi"
  last_name                   = "Admin"
  linux_username              = var.pepsi_admin_username
  linux_password_wo           = var.pepsi_admin_password
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = var.pepsi_admin_username
  windows_password_wo         = var.pepsi_admin_password
  windows_password_wo_version = 1
  provider                    = hpe.master-tenant
}

resource "hpe_morpheus_user" "pepsi" {
  count                       = 4 
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id
  username                    = "pepsi${count.index}"
  email                       = "pepsi${count.index}@testacc.com"
  password_wo                 = var.pepsi_password
  password_wo_version         = 1
  role_ids                    = [hpe_morpheus_role.pepsi_user_role.id]
  first_name                  = "Pepsi"
  last_name                   = "User${count.index}"
  linux_username              = "pepsi${count.index}"
  linux_password_wo           = var.pepsi_password
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = "pepsi${count.index}"
  windows_password_wo         = var.pepsi_password
  windows_password_wo_version = 1
  provider                    = hpe.master-tenant
  depends_on = [
    hpe_morpheus_role.pepsi_user_role
  ]
}
