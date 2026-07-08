###############################################################################
# Per-tenant instance expiration policies
#
# Each tenant gets a fixed-expiration lifecycle policy scoped to that tenant's
# infrastructure group (clouds.tf): instances provisioned into the group are
# given a hard expiration date N days out (Coke = 3, Pepsi = 4; see
# local.tenant_expiration_days).
#
# Like the groups they are scoped to, the policies are created THROUGH each
# tenant's sub-tenant provider (hpe.coke / hpe.pepsi), so each policy lives
# inside its own sub-tenant alongside its group. The bootstrap admin those
# providers authenticate as carries the "admin-policies" feature permission
# (roles.tf ceiling). Provider aliases can't be selected dynamically, so -- as
# with the groups -- the policies are declared once per tenant rather than via
# for_each. The associated_resource_id reference to each group also orders
# creation after the group (and therefore after the bootstrap admin) exists.
###############################################################################

resource "hpe_morpheus_policy" "coke_expiration" {
  provider = hpe.coke

  name                     = "${local.tenants["coke"].name} Expiration Policy"
  description              = "Fixed ${local.tenant_expiration_days["coke"]}-day instance expiration for the ${local.tenants["coke"].name} tenant"
  associated_resource_type = "Group"
  associated_resource_id   = hpe_morpheus_group.coke.id
  enabled                  = true

  policy_type = {
    code = "lifecycle"
  }

  # Fixed expiration: instances expire lifecycleAge days after provisioning.
  # Extensions and auto-renew are disabled so the expiration is a hard deadline.
  # Disabling extensions also avoids Morpheus rejecting the policy with "Approval
  # Integration must be selected" -- it requires an approval integration whenever
  # user-requested extensions are enabled.
  config = {
    lifecycleType                     = "fixed"
    lifecycleAge                      = tostring(local.tenant_expiration_days["coke"])
    lifecycleAutoRenew                = "off"
    lifecycleAllowExtend              = "off"
    lifecycleExtensionsBeforeApproval = "0"
  }
}

resource "hpe_morpheus_policy" "pepsi_expiration" {
  provider = hpe.pepsi

  name                     = "${local.tenants["pepsi"].name} Expiration Policy"
  description              = "Fixed ${local.tenant_expiration_days["pepsi"]}-day instance expiration for the ${local.tenants["pepsi"].name} tenant"
  associated_resource_type = "Group"
  associated_resource_id   = hpe_morpheus_group.pepsi.id
  enabled                  = true

  policy_type = {
    code = "lifecycle"
  }

  # Fixed expiration: instances expire lifecycleAge days after provisioning.
  # Extensions and auto-renew are disabled so the expiration is a hard deadline.
  # Disabling extensions also avoids Morpheus rejecting the policy with "Approval
  # Integration must be selected" -- it requires an approval integration whenever
  # user-requested extensions are enabled.
  config = {
    lifecycleType                     = "fixed"
    lifecycleAge                      = tostring(local.tenant_expiration_days["pepsi"])
    lifecycleAutoRenew                = "off"
    lifecycleAllowExtend              = "off"
    lifecycleExtensionsBeforeApproval = "0"
  }
}
