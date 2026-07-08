data "hpe_morpheus_role" "coke_user_role_tenant" {
  provider = hpe.coke-master-tenant
  name     = "Coke User Role"
  depends_on = [
    hpe_morpheus_role.coke_user_role,
    hpe_morpheus_user.coke_admin,
  ]
}

# Forces coke_admin.role_ids to be unknown at plan time on create, so Terraform
# skips its post-apply consistency check. Morpheus swaps the master multitenant
# role id for the subtenant's copy id, which would otherwise fail that check.
# input still resolves to the master role id at apply, so Morpheus assigns the
# correct role. ignore_changes on the user pins the returned copy id thereafter.
resource "terraform_data" "coke_admin_role_ref" {
  input = hpe_morpheus_role.coke_admin_role.id
}

resource "hpe_morpheus_user" "coke_admin" {
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id
  username                    = var.coke_admin_username
  email                       = "${var.coke_admin_username}@testacc.com"
  password_wo                 = var.coke_admin_password
  password_wo_version         = 1
  role_ids                    = [terraform_data.coke_admin_role_ref.output]
  first_name                  = "Coke"
  last_name                   = "Admin"
  linux_username              = var.coke_admin_username
  linux_password_wo           = var.coke_admin_password
  linux_password_wo_version   = 1
  linux_key_pair_id           = 100
  receive_notifications       = false
  windows_username            = var.coke_admin_username
  windows_password_wo         = var.coke_admin_password
  windows_password_wo_version = 1
  provider                    = hpe.master-tenant

  lifecycle {
    ignore_changes = [role_ids]
  }
}

resource "hpe_morpheus_user" "coke" {
  count                       = 2
  tenant_id                   = hpe_morpheus_tenant.coke-master-tenant.id
  username                    = "coke${count.index}"
  email                       = "coke${count.index}@testacc.com"
  password_wo                 = var.coke_password
  password_wo_version         = 1
  role_ids                    = [data.hpe_morpheus_role.coke_user_role_tenant.id]
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
  depends_on = [
    hpe_morpheus_role.coke_user_role
  ]
}
