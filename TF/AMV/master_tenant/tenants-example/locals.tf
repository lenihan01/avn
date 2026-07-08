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
  # Scoped to tenant-relevant Administration and integration features;
  # appliance/master-only codes (admin-appliance, admin-licenses, admin-plugins,
  # admin-clients, admin-packages, admin-whitelabel) are intentionally omitted.
  # Every code in this list is granted at "full" access.
  #
  # admin-health is the exception: it is appliance-scoped but still granted to
  # every role by request -- and only at "read", because the Health feature does
  # not support "full". It is therefore NOT in this ("full") list; it is added
  # separately in tenant_ceiling_permissions below.
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

    # Integration features.
    #   admin-cm ("Integrations") is what actually gates the create/update API
    #     the provider uses (POST/PUT /api/integrations) -- verified in the
    #     Morpheus IntegrationsController.save/update actions, which require
    #     admin-cm OR infrastructure-network-integrations at "full" access.
    #   integrations-ansible does NOT authorize those API calls, but IS required
    #     to view/edit the Ansible integration's own config after creation and to
    #     use it during provisioning (the /integration/ansible controller). Keep
    #     it: without it the tenant admin cannot edit the integration.
    "admin-cm",
    "integrations-ansible",

    # Automation features.
    #   tasks ("Tasks") gates the task create/update/delete API the provider
    #     uses (POST/PUT/DELETE /api/tasks) -- verified in the Morpheus
    #     TasksController, whose class requires tasks at "read"/"full" and whose
    #     save/update/delete actions each require tasks at "full" access. The
    #     Coke sub-tenant admin needs it to create the shell task (tasks.tf).
    #   workflows ("Workflows") gates the workflow (task set) create/update/
    #     delete API (POST/PUT/DELETE /api/task-sets) -- verified in the Morpheus
    #     TaskSetsController, whose class requires workflows at "read"/"full" and
    #     whose save/update/delete actions each require workflows at "full". The
    #     Coke sub-tenant admin needs it to create the provisioning workflow
    #     (workflows.tf).
    "tasks",
    "workflows",

    # Library features.
    #   admin-containers ("Library") gates the library instance-type create/
    #     update/delete API the provider uses (POST/PUT/DELETE
    #     /api/library/instance-types) -- verified in the Morpheus
    #     LibraryInstanceTypesController, whose class requires admin-containers at
    #     "read"/"full" and whose save/update/delete actions each require it at
    #     "full" access. The Coke sub-tenant admin needs it to create the
    #     instance type (instance_types.tf). NOTE: that endpoint is also gated by
    #     the "library" appliance LICENSE feature (not a role permission) -- if the
    #     appliance is not licensed for Library the create fails with a license
    #     error rather than a 403.
    "admin-containers",

    # Provisioning features.
    #   provisioning-instances-list ("Provisioning: Instances" list/view) is
    #     granted to EVERY tenant -- both the tenant_admin role and the base-role
    #     ceiling (roles.tf) -- so each tenant admin can list its instances.
    #     Unlike Coke's provisioning-* extras (tenant_extra_feature_codes, which
    #     are Coke-only), this one is shared by all tenants, so it belongs in this
    #     shared ceiling. Granted at "full" like the rest of this list.
    "provisioning-instances-list",
  ]

  # Materialized feature-permission ceiling used by the base role (the ceiling
  # itself) and the tenant_admin role (roles.tf): every tenant_ceiling_features
  # code at "full", plus admin-health at "read" (the Health feature only supports
  # read/none, not full). Adding admin-health here raises the ceiling and is NOT
  # retroactive, so already-deployed tenants must be recreated to pick it up.
  tenant_ceiling_permissions = concat(
    [for code in local.tenant_ceiling_features : { code = code, access = "full" }],
    [{ code = "admin-health", access = "read" }],
  )

  # Per-tenant EXTRA feature permissions, layered on top of the shared ceiling
  # (tenant_ceiling_permissions) for that tenant's base (ceiling) AND admin roles
  # (roles.tf). Keyed by tenant; a tenant with no entry gets no extras. Because
  # the base role is the tenant's permission ceiling, listing a code here -- which
  # also feeds the base role -- is what lets the admin role's sub-tenant copy keep
  # it.
  #
  # Coke additionally gets every provisioning-* feature at "full" access. As with
  # any ceiling change this is NOT retroactive: the Coke tenant must be recreated
  # (destroy/apply) for the raised ceiling to reach its tenant-local admin copy.
  tenant_extra_feature_codes = {
    coke = [
      "provisioning-add",
      "provisioning-admin",
      "provisioning-clone",
      "provisioning-delete",
      "provisioning-edit",
      "provisioning-environment",
      "provisioning-execute-script",
      "provisioning-execute-task",
      "provisioning-execute-workflow",
      "provisioning-force-delete",
      "provisioning-import-image",
      "provisioning-lock",
      "provisioning-power",
      "provisioning-reconfigure",
      "provisioning-reconfigure-add-disk",
      "provisioning-reconfigure-add-network",
      "provisioning-reconfigure-change-plan",
      "provisioning-reconfigure-disk-type",
      "provisioning-reconfigure-modify-disk",
      "provisioning-reconfigure-modify-network",
      "provisioning-reconfigure-remove-disk",
      "provisioning-reconfigure-remove-network",
      "provisioning-remove-control",
      "provisioning-scale",
      "provisioning-settings",
      "provisioning-state",
    ]
  }

  # Full feature-permission list applied to each tenant's base + admin roles: the
  # shared ceiling (tenant_ceiling_permissions) plus that tenant's extras at
  # "full" access. Tenants with no extras just get the shared ceiling.
  tenant_role_permissions = {
    for tenant in keys(local.tenants) : tenant => concat(
      local.tenant_ceiling_permissions,
      [for code in lookup(local.tenant_extra_feature_codes, tenant, []) : { code = code, access = "full" }],
    )
  }

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

  # Per-tenant instance expiration. Each tenant's group (clouds.tf) gets a
  # fixed-expiration lifecycle policy (policies.tf) that expires instances
  # provisioned into the group after this many days.
  tenant_expiration_days = {
    coke  = 3
    pepsi = 4
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
