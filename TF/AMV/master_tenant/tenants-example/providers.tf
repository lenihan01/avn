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
# IMPORTANT: we do NOT use the `tenant_subdomain` attribute. In provider v1.5.0
# it is formatted with a DOUBLED backslash -- morpheus/sdkv2/client/client.go
# builds the login name with a Go raw-string literal `fmt.Sprintf(`%s\\%s`, ...)`,
# which yields "coke\\coke-admin" (two backslashes) instead of the required
# "coke\coke-admin" (one). That makes every sub-tenant login fail with a 401,
# which the role data source surfaces as "GET failed for role ...". Instead we
# embed the correct single-backslash "subdomain\username" directly in `username`
# (Morpheus form-encodes the backslash to %5C), which authenticates correctly.
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
