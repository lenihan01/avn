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
