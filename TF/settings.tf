###############################################################################
# Appliance-wide provisioning settings
#
# Sets the default cloud-init credentials Morpheus injects into provisioned
# Linux instances. These live on the provisioning settings
# (/api/provisioning-settings), exposed by hpe_morpheus_setting_provisioning --
# NOT hpe_morpheus_setting_appliance, which has no cloud-init fields.
#
# This is a global (master-tenant) singleton setting, so it is created by the
# default master provider. Only the two cloud-init attributes are managed here;
# every other provisioning setting is left at its current appliance value (each
# attribute is optional/computed in the provider).
###############################################################################

resource "hpe_morpheus_setting_provisioning" "this" {
  cloudinit_username = var.cloudinit_username
  cloudinit_password = var.cloudinit_password
}
