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

# Sub-tenant providers. Each authenticates as that tenant's bootstrap admin,
# which is created via the Morpheus API in users.tf.
#
# The login is written as "subdomain\username" (a single backslash) directly in
# `username`. That is the format the Morpheus API expects for a sub-tenant user;
# it is form-encoded to "subdomain%5Cusername" on the wire (e.g. "2%5Cjdoe" in
# the provider's own API docs). We embed it here rather than using the provider's
# `tenant_subdomain` attribute because, in v1.5.0, tenant_subdomain composes the
# login with a DOUBLED backslash (morpheus/utils/clientfactory/clientfactory.go:
# `fmt.Sprintf(`%s\\%s`, ...)` -> "coke\\coke-admin"). This Morpheus happens to
# accept the doubled form, but the single-backslash login above is what the
# documented API contract specifies.
#
# Login is lazy (per request), so these providers can be configured before the
# admin exists; the data sources that use them (users.tf) depend_on the admin
# bootstrap and are deferred to apply time, so everything is created in a single
# apply.
provider "hpe" {
  alias = "coke"
  morpheus {
    url      = var.morpheus_url
    username = "coke\\${var.coke_admin_username}"
    password = var.coke_admin_password
    insecure = var.morpheus_insecure
  }
}

provider "hpe" {
  alias = "pepsi"
  morpheus {
    url      = var.morpheus_url
    username = "pepsi\\${var.pepsi_admin_username}"
    password = var.pepsi_admin_password
    insecure = var.morpheus_insecure
  }
}
