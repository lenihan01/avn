###############################################################################
# Per-tenant infrastructure group + VMware cloud
#
# Each tenant gets its own Server group and a VMware (vCenter) cloud assigned to
# that group. Patterned on the production coke_clouds.tf/pepsi_clouds.tf in the
# parent directory, adapted to this module's per-tenant structure.
#
# Groups: hpe_morpheus_group has no tenant_id -- a group belongs to whichever
# tenant its provider is authenticated as. So each group is created through that
# tenant's sub-tenant provider (hpe.coke / hpe.pepsi), which logs in as the
# bootstrap admin. That admin needs the "admin-groups" feature permission,
# granted on the tenant_admin role AND raised in the base role ceiling
# (hpe_morpheus_role.base)
# (roles.tf) so it survives into the tenant-local role copy. Provider aliases
# can't be selected dynamically, so the groups are declared once per tenant
# (like the role data sources in users.tf). depends_on defers creation until the
# bootstrap admin exists (for auth).
#
# Clouds: created by the master provider (the default hpe provider) like the
# parent module, with tenant_id targeting the sub-tenant and group_id pointing at
# that tenant's group.
###############################################################################

resource "hpe_morpheus_group" "coke" {
  provider = hpe.coke
  name     = "${local.tenants["coke"].name} Group"
  code     = "${local.tenants["coke"].subdomain}-group"

  depends_on = [terraform_data.admin]
}

resource "hpe_morpheus_group" "pepsi" {
  provider = hpe.pepsi
  name     = "${local.tenants["pepsi"].name} Group"
  code     = "${local.tenants["pepsi"].subdomain}-group"

  depends_on = [terraform_data.admin]
}

# Group owned by the Coke-Finance sub-tenant. Created through the
# hpe.coke_finance provider (which logs in as the Coke-Finance bootstrap admin),
# so the group belongs to Coke-Finance. depends_on defers creation until that
# admin exists (for auth). Hosts the MVM private cloud below.
resource "hpe_morpheus_group" "coke_finance" {
  provider = hpe.coke_finance
  name     = "Coke HVM Group"
  code     = "coke-hvm-group"

  depends_on = [terraform_data.coke_subtenant_admin]
}

resource "hpe_morpheus_cloud" "vmware" {
  for_each = local.cloud_config

  name      = each.value.name
  tenant_id = hpe_morpheus_tenant.this[each.key].id
  group_id  = local.tenant_group_ids[each.key]

  code            = each.value.code
  enabled         = true
  visibility      = "private"
  cloud_type_code = "vmware"

  agent_install_mode       = "ssh"
  appliance_url            = var.morpheus_url
  auto_recover_power_state = true
  import_existing_vms      = "off"

  costing_mode    = "costing"
  guidance_mode   = "off"
  security_mode   = "off"
  keyboard_layout = "us"

  # Generic VMware cloud configuration passed straight to the Morpheus API
  # (matches the parent module's config block).
  config = {
    apiUrl                    = each.value.api_url
    apiVersion                = "7.0"
    datacenter                = each.value.datacenter
    cluster                   = each.value.cluster
    username                  = each.value.username
    password                  = each.value.password
    certificateProvider       = "internal"
    enable_hypervisor_console = true
  }
}

# Private Cloud (cloud_type_code "standard"), owned by the Coke-Finance
# sub-tenant and assigned to the "Coke HVM Group" above. Like the VMware clouds,
# it is created by the master provider with tenant_id targeting the sub-tenant.
#
# NOTE: this appliance has no MVM / HPE-VM (KVM) cloud type installed -- its
# /api/zone-types list offers no such code, and "standard" ("Private Cloud") is
# the only generic private cloud available. If the MVM/HPE-VM tech pack is
# enabled on the appliance later, switch cloud_type_code to that code.
resource "hpe_morpheus_cloud" "coke_finance_hvm" {
  name      = "Coke Finance HVM Cloud 1"
  tenant_id = hpe_morpheus_tenant.coke_subtenant["coke_finance"].id
  group_id  = hpe_morpheus_group.coke_finance.id

  code            = "cokefinancehvmcloud1"
  enabled         = true
  visibility      = "private"
  cloud_type_code = "standard"

  agent_install_mode       = "ssh"
  appliance_url            = var.morpheus_url
  auto_recover_power_state = true
  import_existing_vms      = "off"

  costing_mode    = "costing"
  guidance_mode   = "off"
  security_mode   = "off"
  keyboard_layout = "us"

  # Standard "Private Cloud" config (matches the provider's documented example).
  # Hosts are added to the cloud manually after it exists.
  config = {
    certificateProvider        = "internal"
    enableNetworkTypeSelection = false
  }
}
