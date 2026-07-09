resource "hpe_morpheus_role" "coke_tenant_role" {
  name        = "Coke Tenant Admin Role"
  description = "Coke Tenant Admin Role"
  role_type   = "tenant"
  provider    = hpe.master-tenant
  permissions = {
    default_instance_type_access = "full"
    default_task_access          = "full"
    default_workflow_access      = "full"
    feature_permissions = [
    {
      "code": "activity",
      "access": "read",
    },
    {
      "code": "provisioning-admin",
      "access": "full",
    },
    {
      "code": "library-advanced-node-type-options",
      "access": "full",
    },
    {
      "code": "reports-analytics",
      "access": "none",
    },
    {
      "code": "integrations-ansible",
      "access": "full",
    },
    {
      "code": "app-templates",
      "access": "full",
    },
    {
      "code": "admin-appliance",
      "access": "none",
    },
    {
      "code": "operations-approvals",
      "access": "full",
    },
    {
      "code": "apps",
      "access": "full",
    },
    {
      "code": "billing",
      "access": "none",
    },
    {
      "code": "service-catalog",
      "access": "full",
    },
    {
      "code": "catalog",
      "access": "full",
    },
    {
      "code": "admin-certificates",
      "access": "full",
    },
    {
      "code": "admin-zones",
      "access": "full",
    },
    {
      "code": "infrastructure-cluster",
      "access": "full",
    },
    {
      "code": "deployments",
      "access": "full",
    },
    {
      "code": "code-repositories",
      "access": "full",
    },
    {
      "code": "admin-servers",
      "access": "full",
    },
    {
      "code": "credentials",
      "access": "full",
    },
    {
      "code": "services-cypher",
      "access": "full",
    },
    {
      "code": "dashboard",
      "access": "read",
    },
    {
      "code": "service-catalog-dashboard",
      "access": "read",
    },
    {
      "code": "infrastructure-network-dhcp-relay",
      "access": "full",
    },
    {
      "code": "infrastructure-network-dhcp-server",
      "access": "full",
    },
    {
      "code": "infrastructure-domains",
      "access": "full",
    },
    {
      "code": "admin-environments",
      "access": "full",
    },
    {
      "code": "provisioning-environment",
      "access": "full",
    },
    {
      "code": "provisioning-execute-script",
      "access": "full",
    },
    {
      "code": "provisioning-execute-task",
      "access": "full",
    },
    {
      "code": "provisioning-execute-workflow",
      "access": "full",
    },
    {
      "code": "execution-request",
      "access": "full",
    },
    {
      "code": "executions",
      "access": "read",
    },
    {
      "code": "lifecycle-extend",
      "access": "full",
    },
    {
      "code": "infrastructure-network-firewalls",
      "access": "full",
    },
    {
      "code": "admin-groups",
      "access": "full",
    },
    {
      "code": "admin-health",
      "access": "read",
    },
    {
      "code": "provisioning-import-image",
      "access": "full",
    },
    {
      "code": "admin-containers",
      "access": "full",
    },
    {
      "code": "provisioning-add",
      "access": "full",
    },
    {
      "code": "provisioning-clone",
      "access": "full",
    },
    {
      "code": "provisioning-delete",
      "access": "full",
    },
    {
      "code": "provisioning-edit",
      "access": "full",
    },
    {
      "code": "provisioning-force-delete",
      "access": "full",
    },
    {
      "code": "provisioning",
      "access": "full",
    },
    {
      "code": "provisioning-lock",
      "access": "full",
    },
    {
      "code": "provisioning-remove-control",
      "access": "full",
    },
    {
      "code": "provisioning-scale",
      "access": "full",
    },
    {
      "code": "provisioning-settings",
      "access": "full",
    },
    {
      "code": "infrastructure-network-integrations",
      "access": "full",
    },
    {
      "code": "admin-cm",
      "access": "full",
    },
    {
      "code": "automation-services",
      "access": "full",
    },
    {
      "code": "operations-invoices",
      "access": "none",
    },
    {
      "code": "infrastructure-ippools",
      "access": "full",
    },
    {
      "code": "job-executions",
      "access": "read",
    },
    {
      "code": "job-templates",
      "access": "full",
    },
    {
      "code": "admin-keypairs",
      "access": "full",
    },
    {
      "code": "services-kubernetes",
      "access": "full",
    },
    {
      "code": "infrastructure-kube-cntl",
      "access": "full",
    },
    {
      "code": "library-packages",
      "access": "full",
    },
    {
      "code": "admin-licenses",
      "access": "full",
    },
    {
      "code": "infrastructure-loadbalancer",
      "access": "full",
    },
    {
      "code": "logs",
      "access": "read",
    },
    {
      "code": "infrastructure-servers-placement",
      "access": "full",
    },
    {
      "code": "infrastructure-networks",
      "access": "full",
    },
    {
      "code": "library-options",
      "access": "full",
    },
    {
      "code": "service-catalog-inventory",
      "access": "full",
    },
    {
      "code": "admin-policies",
      "access": "full",
    },
    {
      "code": "admin-global-policies",
      "access": "full",
    },
    {
      "code": "provisioning-power",
      "access": "full",
    },
    {
      "code": "admin-provisioningSettings",
      "access": "full",
    },
    {
      "code": "infrastructure-proxies",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-change-plan",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-disk-type",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-network",
      "access": "full",
    },
    {
      "code": "terminal",
      "access": "full",
    },
    {
      "code": "terminal-access",
      "access": "full",
    },
    {
      "code": "reports",
      "access": "full",
    },
    {
      "code": "lifecycle-retry-cancel",
      "access": "full",
    },
    {
      "code": "admin-roles",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-firewalls",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-interfaces",
      "access": "full",
    },
    {
      "code": "infrastructure-nat",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-redistribution",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-routes",
      "access": "full",
    },
    {
      "code": "infrastructure-routers",
      "access": "full",
    },
    {
      "code": "scheduling-execute",
      "access": "full",
    },
    {
      "code": "scheduling-power",
      "access": "full",
    },
    {
      "code": "infrastructure-securityGroups",
      "access": "full",
    },
    {
      "code": "admin-server-devices",
      "access": "full",
    },
    {
      "code": "infrastructure-network-server-groups",
      "access": "full",
    },
    {
      "code": "admin-server-software",
      "access": "full",
    },
    {
      "code": "admin-servicePlans",
      "access": "read",
    },
    {
      "code": "snapshots",
      "access": "full",
    },
    {
      "code": "snapshots-linked-clone",
      "access": "full",
    },
    {
      "code": "provisioning-state",
      "access": "full",
    },
    {
      "code": "tasks",
      "access": "full",
    },
    {
      "code": "task-scripts",
      "access": "full",
    },
    {
      "code": "library-templates",
      "access": "full",
    },
    {
      "code": "thresholds",
      "access": "full",
    },
    {
      "code": "infrastructure-servers-maintenance",
      "access": "full",
    },
    {
      "code": "trust-services",
      "access": "full",
    },
    {
      "code": "admin-users",
      "access": "read",
    },
    {
      "code": "virtual-images",
      "access": "full",
    },
    {
      "code": "workflows",
      "access": "full",
    }
    ]
  }
}


resource "hpe_morpheus_role" "coke_admin_role" {
  name        = "Coke Admin Role"
  multitenant = true
  description = "Coke Admin Role"
  role_type   = "user"
  provider    = hpe.master-tenant
  permissions = {
    default_instance_type_access = "full"
    default_group_access = "full"
    default_task_access          = "full"
    default_workflow_access      = "full"
    feature_permissions = [
    {
      "code": "activity",
      "access": "read",
    },
    {
      "code": "provisioning-admin",
      "access": "full",
    },
    {
      "code": "library-advanced-node-type-options",
      "access": "full",
    },
    {
      "code": "reports-analytics",
      "access": "none",
    },
    {
      "code": "integrations-ansible",
      "access": "full",
    },
    {
      "code": "app-templates",
      "access": "full",
    },
    {
      "code": "admin-appliance",
      "access": "none",
    },
    {
      "code": "operations-approvals",
      "access": "full",
    },
    {
      "code": "apps",
      "access": "full",
    },
    {
      "code": "billing",
      "access": "none",
    },
    {
      "code": "service-catalog",
      "access": "full",
    },
    {
      "code": "catalog",
      "access": "full",
    },
    {
      "code": "admin-certificates",
      "access": "full",
    },
    {
      "code": "admin-zones",
      "access": "full",
    },
    {
      "code": "infrastructure-cluster",
      "access": "full",
    },
    {
      "code": "deployments",
      "access": "full",
    },
    {
      "code": "code-repositories",
      "access": "full",
    },
    {
      "code": "admin-servers",
      "access": "full",
    },
    {
      "code": "credentials",
      "access": "full",
    },
    {
      "code": "services-cypher",
      "access": "full",
    },
    {
      "code": "dashboard",
      "access": "read",
    },
    {
      "code": "service-catalog-dashboard",
      "access": "read",
    },
    {
      "code": "infrastructure-network-dhcp-relay",
      "access": "full",
    },
    {
      "code": "infrastructure-network-dhcp-server",
      "access": "full",
    },
    {
      "code": "infrastructure-domains",
      "access": "full",
    },
    {
      "code": "admin-environments",
      "access": "full",
    },
    {
      "code": "provisioning-environment",
      "access": "full",
    },
    {
      "code": "provisioning-execute-script",
      "access": "full",
    },
    {
      "code": "provisioning-execute-task",
      "access": "full",
    },
    {
      "code": "provisioning-execute-workflow",
      "access": "full",
    },
    {
      "code": "execution-request",
      "access": "full",
    },
    {
      "code": "executions",
      "access": "read",
    },
    {
      "code": "lifecycle-extend",
      "access": "full",
    },
    {
      "code": "infrastructure-network-firewalls",
      "access": "full",
    },
    {
      "code": "admin-groups",
      "access": "full",
    },
    {
      "code": "admin-health",
      "access": "read",
    },
    {
      "code": "provisioning-import-image",
      "access": "full",
    },
    {
      "code": "admin-containers",
      "access": "full",
    },
    {
      "code": "provisioning-add",
      "access": "full",
    },
    {
      "code": "provisioning-clone",
      "access": "full",
    },
    {
      "code": "provisioning-delete",
      "access": "full",
    },
    {
      "code": "provisioning-edit",
      "access": "full",
    },
    {
      "code": "provisioning-force-delete",
      "access": "full",
    },
    {
      "code": "provisioning",
      "access": "full",
    },
    {
      "code": "provisioning-lock",
      "access": "full",
    },
    {
      "code": "provisioning-remove-control",
      "access": "full",
    },
    {
      "code": "provisioning-scale",
      "access": "full",
    },
    {
      "code": "provisioning-settings",
      "access": "full",
    },
    {
      "code": "infrastructure-network-integrations",
      "access": "full",
    },
    {
      "code": "admin-cm",
      "access": "full",
    },
    {
      "code": "automation-services",
      "access": "full",
    },
    {
      "code": "operations-invoices",
      "access": "none",
    },
    {
      "code": "infrastructure-ippools",
      "access": "full",
    },
    {
      "code": "job-executions",
      "access": "read",
    },
    {
      "code": "job-templates",
      "access": "full",
    },
    {
      "code": "admin-keypairs",
      "access": "full",
    },
    {
      "code": "services-kubernetes",
      "access": "full",
    },
    {
      "code": "infrastructure-kube-cntl",
      "access": "full",
    },
    {
      "code": "library-packages",
      "access": "full",
    },
    {
      "code": "admin-licenses",
      "access": "full",
    },
    {
      "code": "infrastructure-loadbalancer",
      "access": "full",
    },
    {
      "code": "logs",
      "access": "read",
    },
    {
      "code": "infrastructure-servers-placement",
      "access": "full",
    },
    {
      "code": "infrastructure-networks",
      "access": "full",
    },
    {
      "code": "library-options",
      "access": "full",
    },
    {
      "code": "service-catalog-inventory",
      "access": "full",
    },
    {
      "code": "admin-policies",
      "access": "full",
    },
    {
      "code": "admin-global-policies",
      "access": "full",
    },
    {
      "code": "provisioning-power",
      "access": "full",
    },
    {
      "code": "admin-provisioningSettings",
      "access": "full",
    },
    {
      "code": "infrastructure-proxies",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-change-plan",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-disk-type",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-network",
      "access": "full",
    },
    {
      "code": "terminal",
      "access": "full",
    },
    {
      "code": "terminal-access",
      "access": "full",
    },
    {
      "code": "reports",
      "access": "full",
    },
    {
      "code": "lifecycle-retry-cancel",
      "access": "full",
    },
    {
      "code": "admin-roles",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-firewalls",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-interfaces",
      "access": "full",
    },
    {
      "code": "infrastructure-nat",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-redistribution",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-routes",
      "access": "full",
    },
    {
      "code": "infrastructure-routers",
      "access": "full",
    },
    {
      "code": "scheduling-execute",
      "access": "full",
    },
    {
      "code": "scheduling-power",
      "access": "full",
    },
    {
      "code": "infrastructure-securityGroups",
      "access": "full",
    },
    {
      "code": "admin-server-devices",
      "access": "full",
    },
    {
      "code": "infrastructure-network-server-groups",
      "access": "full",
    },
    {
      "code": "admin-server-software",
      "access": "full",
    },
    {
      "code": "admin-servicePlans",
      "access": "read",
    },
    {
      "code": "snapshots",
      "access": "full",
    },
    {
      "code": "snapshots-linked-clone",
      "access": "full",
    },
    {
      "code": "provisioning-state",
      "access": "full",
    },
    {
      "code": "tasks",
      "access": "full",
    },
    {
      "code": "task-scripts",
      "access": "full",
    },
    {
      "code": "library-templates",
      "access": "full",
    },
    {
      "code": "thresholds",
      "access": "full",
    },
    {
      "code": "infrastructure-servers-maintenance",
      "access": "full",
    },
    {
      "code": "trust-services",
      "access": "full",
    },
    {
      "code": "admin-users",
      "access": "read",
    },
    {
      "code": "virtual-images",
      "access": "full",
    },
    {
      "code": "workflows",
      "access": "full",
    }
    ]
  }
}

resource "hpe_morpheus_role" "coke_user_role" {
  name        = "Coke User Role"
  multitenant = true 
  description = "Coke User Role"
  role_type   = "user"
  provider    = hpe.master-tenant
  permissions = {
    default_group_access = "full"
    default_instance_type_access = "full"
    default_task_access          = "full"
    default_workflow_access      = "full"
    feature_permissions = [
    {
      "code": "activity",
      "access": "read",
    },
    {
      "code": "provisioning-admin",
      "access": "full",
    },
    {
      "code": "library-advanced-node-type-options",
      "access": "full",
    },
    {
      "code": "reports-analytics",
      "access": "none",
    },
    {
      "code": "integrations-ansible",
      "access": "full",
    },
    {
      "code": "app-templates",
      "access": "full",
    },
    {
      "code": "admin-appliance",
      "access": "none",
    },
    {
      "code": "operations-approvals",
      "access": "full",
    },
    {
      "code": "apps",
      "access": "full",
    },
    {
      "code": "billing",
      "access": "none",
    },
    {
      "code": "service-catalog",
      "access": "full",
    },
    {
      "code": "catalog",
      "access": "full",
    },
    {
      "code": "admin-certificates",
      "access": "full",
    },
    {
      "code": "admin-zones",
      "access": "full",
    },
    {
      "code": "infrastructure-cluster",
      "access": "full",
    },
    {
      "code": "deployments",
      "access": "full",
    },
    {
      "code": "code-repositories",
      "access": "full",
    },
    {
      "code": "admin-servers",
      "access": "full",
    },
    {
      "code": "credentials",
      "access": "full",
    },
    {
      "code": "services-cypher",
      "access": "full",
    },
    {
      "code": "dashboard",
      "access": "read",
    },
    {
      "code": "service-catalog-dashboard",
      "access": "read",
    },
    {
      "code": "infrastructure-network-dhcp-relay",
      "access": "full",
    },
    {
      "code": "infrastructure-network-dhcp-server",
      "access": "full",
    },
    {
      "code": "infrastructure-domains",
      "access": "full",
    },
    {
      "code": "admin-environments",
      "access": "full",
    },
    {
      "code": "provisioning-environment",
      "access": "full",
    },
    {
      "code": "provisioning-execute-script",
      "access": "full",
    },
    {
      "code": "provisioning-execute-task",
      "access": "full",
    },
    {
      "code": "provisioning-execute-workflow",
      "access": "full",
    },
    {
      "code": "execution-request",
      "access": "full",
    },
    {
      "code": "executions",
      "access": "read",
    },
    {
      "code": "lifecycle-extend",
      "access": "full",
    },
    {
      "code": "infrastructure-network-firewalls",
      "access": "full",
    },
    {
      "code": "admin-groups",
      "access": "full",
    },
    {
      "code": "admin-health",
      "access": "read",
    },
    {
      "code": "provisioning-import-image",
      "access": "full",
    },
    {
      "code": "admin-containers",
      "access": "full",
    },
    {
      "code": "provisioning-add",
      "access": "full",
    },
    {
      "code": "provisioning-clone",
      "access": "full",
    },
    {
      "code": "provisioning-delete",
      "access": "full",
    },
    {
      "code": "provisioning-edit",
      "access": "full",
    },
    {
      "code": "provisioning-force-delete",
      "access": "full",
    },
    {
      "code": "provisioning",
      "access": "full",
    },
    {
      "code": "provisioning-lock",
      "access": "full",
    },
    {
      "code": "provisioning-remove-control",
      "access": "full",
    },
    {
      "code": "provisioning-scale",
      "access": "full",
    },
    {
      "code": "provisioning-settings",
      "access": "full",
    },
    {
      "code": "infrastructure-network-integrations",
      "access": "full",
    },
    {
      "code": "admin-cm",
      "access": "full",
    },
    {
      "code": "automation-services",
      "access": "full",
    },
    {
      "code": "operations-invoices",
      "access": "none",
    },
    {
      "code": "infrastructure-ippools",
      "access": "full",
    },
    {
      "code": "job-executions",
      "access": "read",
    },
    {
      "code": "job-templates",
      "access": "full",
    },
    {
      "code": "admin-keypairs",
      "access": "full",
    },
    {
      "code": "services-kubernetes",
      "access": "full",
    },
    {
      "code": "infrastructure-kube-cntl",
      "access": "full",
    },
    {
      "code": "library-packages",
      "access": "full",
    },
    {
      "code": "admin-licenses",
      "access": "full",
    },
    {
      "code": "infrastructure-loadbalancer",
      "access": "full",
    },
    {
      "code": "logs",
      "access": "read",
    },
    {
      "code": "infrastructure-servers-placement",
      "access": "full",
    },
    {
      "code": "infrastructure-networks",
      "access": "full",
    },
    {
      "code": "library-options",
      "access": "full",
    },
    {
      "code": "service-catalog-inventory",
      "access": "full",
    },
    {
      "code": "admin-policies",
      "access": "full",
    },
    {
      "code": "admin-global-policies",
      "access": "full",
    },
    {
      "code": "provisioning-power",
      "access": "full",
    },
    {
      "code": "admin-provisioningSettings",
      "access": "full",
    },
    {
      "code": "infrastructure-proxies",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-change-plan",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-disk-type",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-disk",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-add-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-modify-network",
      "access": "full",
    },
    {
      "code": "provisioning-reconfigure-remove-network",
      "access": "full",
    },
    {
      "code": "terminal",
      "access": "full",
    },
    {
      "code": "terminal-access",
      "access": "full",
    },
    {
      "code": "reports",
      "access": "full",
    },
    {
      "code": "lifecycle-retry-cancel",
      "access": "full",
    },
    {
      "code": "admin-roles",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-firewalls",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-interfaces",
      "access": "full",
    },
    {
      "code": "infrastructure-nat",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-redistribution",
      "access": "full",
    },
    {
      "code": "infrastructure-network-router-routes",
      "access": "full",
    },
    {
      "code": "infrastructure-routers",
      "access": "full",
    },
    {
      "code": "scheduling-execute",
      "access": "full",
    },
    {
      "code": "scheduling-power",
      "access": "full",
    },
    {
      "code": "infrastructure-securityGroups",
      "access": "full",
    },
    {
      "code": "admin-server-devices",
      "access": "full",
    },
    {
      "code": "infrastructure-network-server-groups",
      "access": "full",
    },
    {
      "code": "admin-server-software",
      "access": "full",
    },
    {
      "code": "admin-servicePlans",
      "access": "read",
    },
    {
      "code": "snapshots",
      "access": "full",
    },
    {
      "code": "snapshots-linked-clone",
      "access": "full",
    },
    {
      "code": "provisioning-state",
      "access": "full",
    },
    {
      "code": "tasks",
      "access": "full",
    },
    {
      "code": "task-scripts",
      "access": "full",
    },
    {
      "code": "library-templates",
      "access": "full",
    },
    {
      "code": "thresholds",
      "access": "full",
    },
    {
      "code": "infrastructure-servers-maintenance",
      "access": "full",
    },
    {
      "code": "trust-services",
      "access": "full",
    },
    {
      "code": "admin-users",
      "access": "read",
    },
    {
      "code": "virtual-images",
      "access": "full",
    },
    {
      "code": "workflows",
      "access": "full",
    }
    ]
  }
}
