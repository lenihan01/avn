# Master-tenant provider. All resources below are created by the master tenant,
# which is the tenant that owns and provisions the Coke and Pepsi sub-tenants.
provider "hpe" {
  morpheus {
    url      = var.morpheus_url
    username = var.morpheus_username
    password = var.morpheus_password
    insecure = var.morpheus_insecure
  }
}

# Sub-tenant providers. Each authenticates as that tenant's bootstrap admin
# (tenant_subdomain prepends "<subdomain>\" to the username at login), so the
# admin user must already exist in the tenant. Login is lazy (per request), so
# these can be configured before the admin exists -- the data sources that use
# them (users.tf) are deferred to apply time via depends_on.
provider "hpe" {
  alias = "coke"
  morpheus {
    url              = var.morpheus_url
    username         = var.coke_admin_username
    password         = var.coke_admin_password
    insecure         = var.morpheus_insecure
    tenant_subdomain = "coke"
  }
}

provider "hpe" {
  alias = "pepsi"
  morpheus {
    url              = var.morpheus_url
    username         = var.pepsi_admin_username
    password         = var.pepsi_admin_password
    insecure         = var.morpheus_insecure
    tenant_subdomain = "pepsi"
  }
}
