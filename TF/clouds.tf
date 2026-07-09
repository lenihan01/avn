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

# Second Pepsi group, created through the hpe.pepsi provider so it belongs to the
# Pepsi tenant. Hosts the bare-metal cloud below.
resource "hpe_morpheus_group" "pepsi_baremetal" {
  provider = hpe.pepsi
  name     = "Pepsi Bare Metal Group"
  code     = "pepsi-bare-metal-group"

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

  # Set explicitly (to the vCenter datacenter) to avoid a provider bug where an
  # unset (null) data_center_name comes back as "" after apply, producing a
  # "Provider produced inconsistent result" error on updates.
  data_center_name = each.value.datacenter

  agent_install_mode       = "ssh"
  appliance_url            = var.morpheus_url
  auto_recover_power_state = true
  # Inventory existing VMs already present in vCenter ("basic" = inventory only,
  # without installing an agent; use "full" to also install agents).
  import_existing_vms = "basic"

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
    # Enable the hypervisor (VNC) console. Morpheus' VMware config expects the
    # key "enableVnc" with an "on"/"off" string; the generic "config" map passes
    # keys through verbatim, so an unrecognised key (e.g. enable_hypervisor_console)
    # is silently ignored by the API. This is the "Enable Hypervisor Console" toggle.
    enableVnc                 = "on"
  }
}

# Force the TOP-LEVEL zone.inventoryLevel on each VMware cloud.
#
# The hpe_morpheus_cloud resource (provider v1.5.0) only writes "inventoryLevel"
# into the cloud's nested "config" map; the request model has no top-level
# inventoryLevel field. Morpheus drives VM inventory off the TOP-LEVEL
# zone.inventoryLevel, which therefore stays "off" and no VMs are inventoried
# (existing hosts are, but serverCounts.vm stays 0). This PUTs the real
# top-level property via the API. The script is idempotent (skips when already
# set) and re-runs if the cloud id or desired level changes.
#
# INVENTORY_LEVEL must match import_existing_vms on the cloud above ("basic").
resource "terraform_data" "vmware_inventory_level" {
  for_each = local.cloud_config

  triggers_replace = {
    cloud_id = hpe_morpheus_cloud.vmware[each.key].id
    level    = "basic"
  }

  provisioner "local-exec" {
    command = "bash \"${path.module}/set_inventory_level.sh\""
    environment = {
      MORPH_URL       = var.morpheus_url
      MORPH_USER      = var.morpheus_username
      MORPH_PASS      = var.morpheus_password
      MORPH_INSECURE  = tostring(var.morpheus_insecure)
      CLOUD_ID        = tostring(hpe_morpheus_cloud.vmware[each.key].id)
      INVENTORY_LEVEL = "basic"
    }
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
#
# Currently disabled: toggle both this cloud and the HVM cluster (clusters.tf)
# with var.create_coke_finance_hvm; it defaults to false, so neither is created.
resource "hpe_morpheus_cloud" "coke_finance_hvm" {
  count = var.create_coke_finance_hvm ? 1 : 0

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

# The HPE bare-metal cloud type is not installed by default -- it appears in the
# appliance's /api/zone-types only once the bare-metal plugin is present. Detect
# that at plan time so the cloud below is created only when the type exists.
#
# The provider's own hpe_morpheus_cloud_type data source can't be used for this:
# its SDK hard-errors ("found 0 Clouds Types") when the type is absent, which
# fails the whole plan. Instead, zone_type_present.sh queries /api/zone-types and
# returns present=true/false, letting count skip the cloud gracefully.
data "external" "baremetal_cloud_type" {
  program = ["bash", "${path.module}/zone_type_present.sh"]

  query = {
    url      = var.morpheus_url
    username = var.morpheus_username
    password = var.morpheus_password
    insecure = tostring(var.morpheus_insecure)
    code     = "hpe-baremetal-plugin.cloud"
  }
}

# HPE bare-metal (BMaaS) cloud, owned by the Pepsi tenant and assigned to the
# "Pepsi Bare Metal Group" above. Like the other clouds it is created by the
# master provider with tenant_id targeting the sub-tenant.
#
# cloud_type_code "hpe-baremetal-plugin.cloud" is the code the appliance's
# /api/zone-types exposes for this plugin. Its only required config option is
# "type" (Credentials) -- "local" means iLO credentials are entered inline
# (iloUsername/iloPassword) rather than referencing a stored credential. All
# other option types (network selection, VNC, BMC CIDR, discovery, etc.) are
# optional and left at their defaults. Supply iLO credentials via the variables
# below; empty values create the cloud without iLO management configured.
#
# count gates creation on the bare-metal plugin being installed (see the
# data.external above): the cloud is created only when the type is present, so
# the config applies cleanly on appliances without the plugin.
resource "hpe_morpheus_cloud" "pepsi_baremetal" {
  count = data.external.baremetal_cloud_type.result.present == "true" ? 1 : 0

  name      = "Pepsi Bare Metal Cloud 1"
  tenant_id = hpe_morpheus_tenant.this["pepsi"].id
  group_id  = hpe_morpheus_group.pepsi_baremetal.id

  code            = "pepsibaremetalcloud1"
  enabled         = true
  visibility      = "private"
  cloud_type_code = "hpe-baremetal-plugin.cloud"

  agent_install_mode       = "ssh"
  appliance_url            = var.morpheus_url
  auto_recover_power_state = true
  import_existing_vms      = "off"

  costing_mode    = "costing"
  guidance_mode   = "off"
  security_mode   = "off"
  keyboard_layout = "us"

  config = {
    type        = "local"
    iloUsername = var.pepsi_baremetal_ilo_username
    iloPassword = var.pepsi_baremetal_ilo_password
  }
}
