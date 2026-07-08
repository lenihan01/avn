data "hpe_morpheus_role" "pepsi_user_role_tenant" {
  provider = hpe.pepsi-master-tenant
  name     = "Pepsi User Role"
  depends_on = [
    hpe_morpheus_role.pepsi_user_role,
    hpe_morpheus_user.pepsi_admin,
  ]
}

# Forces pepsi_admin.role_ids to be unknown at plan time on create, so Terraform
# skips its post-apply consistency check. Morpheus swaps the master multitenant
# role id for the subtenant's copy id, which would otherwise fail that check.
# input still resolves to the master role id at apply, so Morpheus assigns the
# correct role. ignore_changes on the user pins the returned copy id thereafter.
resource "terraform_data" "pepsi_admin_role_ref" {
  input = hpe_morpheus_role.pepsi_admin_role.id
}

resource "hpe_morpheus_user" "pepsi_admin" {
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id
  username                    = var.pepsi_admin_username
  email                       = "${var.pepsi_admin_username}@testacc.com"
  password_wo                 = var.pepsi_admin_password
  password_wo_version         = 1
  role_ids                    = [terraform_data.pepsi_admin_role_ref.output]
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

  lifecycle {
    ignore_changes = [role_ids]
  }
}

resource "hpe_morpheus_user" "pepsi" {
  count                       = 4
  tenant_id                   = hpe_morpheus_tenant.pepsi-master-tenant.id
  username                    = "pepsi${count.index}"
  email                       = "pepsi${count.index}@testacc.com"
  password_wo                 = var.pepsi_password
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.pepsi_user_role_tenant.id]
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
