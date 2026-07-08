# Definition of the two tenants to create. Add another entry here to create
# more tenants -- roles, tenants and outputs all fan out from this map.
locals {
  tenants = {
    coke = {
      name        = "Coke"
      subdomain   = "coke"
      description = "Coke tenant"
    }
    pepsi = {
      name        = "Pepsi"
      subdomain   = "pepsi"
      description = "Pepsi tenant"
    }
  }

  # Feature-permission ceiling shared by every tenant's base role (roles.tf).
  # The base (account) role caps what any role in the tenant may grant, and that
  # cap is materialized when roles are seeded into the tenant. It is deliberately
  # broad here so that granting any of these to the (multitenant) tenant_admin /
  # tenant_user roles later propagates to the sub-tenant copies on a plain
  # `terraform apply` -- only ADDING a new code to this list raises the ceiling,
  # which is not retroactive and needs the tenant to be recreated.
  #
  # Scoped to tenant-relevant Administration features; appliance/master-only
  # codes (admin-appliance, admin-licenses, admin-plugins, admin-clients,
  # admin-packages, admin-health, admin-whitelabel) are intentionally omitted.
  tenant_ceiling_features = [
    "admin-roles",
    "admin-users",
    "admin-groups",
    "admin-zones",
    "admin-servers",
    "admin-server-software",
    "admin-server-devices",
    "admin-servicePlans",
    "admin-policies",
    "admin-global-policies",
    "admin-environments",
    "admin-keypairs",
    "admin-certificates",
    "admin-profiles",
    "admin-provisioningSettings",
    "admin-backupSettings",
    "admin-monitorSettings",
    "admin-guidanceSettings",
    "admin-logSettings",
    "admin-identity-sources",
  ]

  # Bootstrap admin credentials per tenant. These users are created via the
  # Morpheus API in users.tf (local-exec); the sub-tenant providers
  # (providers.tf) then authenticate as them to resolve tenant-local roles.
  admin_creds = {
    coke = {
      username = var.coke_admin_username
      password = var.coke_admin_password
    }
    pepsi = {
      username = var.pepsi_admin_username
      password = var.pepsi_admin_password
    }
  }

  # Per-tenant VMware (vCenter) cloud connection settings. Kept separate from
  # local.tenants so the sensitive credentials don't taint the tenant/role plan
  # output. clouds.tf fans out over this map.
  cloud_config = {
    coke = {
      name       = "Coke VMWare Cloud 1"
      code       = "cokevmwarecloud1"
      api_url    = var.coke_cloud_url
      datacenter = var.coke_cloud_datacenter
      cluster    = var.coke_cloud_cluster
      username   = var.coke_cloud_username
      password   = var.coke_cloud_password
    }
    pepsi = {
      name       = "Pepsi VMWare Cloud 1"
      code       = "pepsivmwarecloud1"
      api_url    = var.pepsi_cloud_url
      datacenter = var.pepsi_cloud_datacenter
      cluster    = var.pepsi_cloud_cluster
      username   = var.pepsi_cloud_username
      password   = var.pepsi_cloud_password
    }
  }

  # Tenant-local group ids, keyed by tenant. The groups are created inside each
  # sub-tenant (clouds.tf) via that tenant's provider; the per-tenant cloud is
  # then assigned to its group. Declared here so clouds.tf can look the id up by
  # each.key while iterating cloud_config.
  tenant_group_ids = {
    coke  = hpe_morpheus_group.coke.id
    pepsi = hpe_morpheus_group.pepsi.id
  }
}
