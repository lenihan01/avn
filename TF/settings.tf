###############################################################################
# Appliance-wide provisioning settings (cloud-init credentials)
#
# Sets the default cloud-init credentials Morpheus injects into provisioned
# Linux instances. These live on the provisioning settings
# (PUT /api/provisioning-settings).
#
# This is set via a local-exec API call rather than the
# hpe_morpheus_setting_provisioning resource, because that resource (provider
# v1.5.0) is unusable against this appliance: after PUTting the settings it
# asserts the response body contains a "provisioningSettings" object and fails
# with "Not found in response: ProvisioningSettings". Morpheus' update endpoint
# only returns {"success":true} (no echoed object), so the update succeeds but
# the provider errors the apply. set_provisioning_settings.sh PUTs directly and
# checks the .success flag instead. Same pattern as bootstrap_admin.sh /
# set_inventory_level.sh.
#
# This is a global (master-tenant) singleton setting, so it authenticates as the
# master admin. Only the two cloud-init attributes are managed here; every other
# provisioning setting is left at its current appliance value. The provisioner
# re-runs only when the username or password changes (triggers_replace).
###############################################################################

resource "terraform_data" "provisioning_settings" {
  triggers_replace = {
    cloudinit_username = var.cloudinit_username
    cloudinit_password = var.cloudinit_password
  }

  provisioner "local-exec" {
    command = "bash \"${path.module}/set_provisioning_settings.sh\""
    environment = {
      MORPH_URL          = var.morpheus_url
      MORPH_USER         = var.morpheus_username
      MORPH_PASS         = var.morpheus_password
      MORPH_INSECURE     = tostring(var.morpheus_insecure)
      CLOUDINIT_USERNAME = var.cloudinit_username
      CLOUDINIT_PASSWORD = var.cloudinit_password
    }
  }
}
