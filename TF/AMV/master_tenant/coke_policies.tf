resource "hpe_morpheus_policy" "coke_expiration" {
  name                     = "Coke Expiration Policy"
  description              = "Set instance expiration and renewal policies"
  associated_resource_type = "Cloud"
  associated_resource_id   = hpe_morpheus_cloud.coke_vmware_1.id
  enabled                  = true
  tenants                  = [hpe_morpheus_tenant.coke-master-tenant.id]
  provider                 = hpe.master-tenant

  policy_type = {
    code = "lifecycle"
  }

  config = {
    # Required
    lifecycleType = "fixed" # Options: "user" (user configurable), "fixed" (fixed expiration)

    # Optional
    lifecycleAge                      = "3"                         # Days until expiration
    lifecycleRenewal                  = "7"                         # Days for renewal window
    lifecycleNotify                   = "1"                         # Days before expiration to notify
    lifecycleMessage                  = "Instance will expire soon" # Notification message
    lifecycleAutoRenew                = "on"                        # Options: "on", "off" - auto renewal lifecycle
    lifecycleAllowExtend              = "off"                       # Options: "on", "off" - allow users to extend
    lifecycleExtensionsBeforeApproval = "0"                         # Number of extensions before requiring approval
    lifecycleHideFixed                = false                       # Hide fixed expiration date from users
    # accountIntegrationId = "1"                                    # ID of your ServiceNow or approval integration
    # workflowType = "workflow"                                     # Options: "workflow" (legacy workflow), "flow" (ServiceNow Flow)
    # lifecycleWorkflowId = "123"                                   # ID of legacy ServiceNow workflow (set if workflowType is 'workflow')
    # flowId = "456"                                                # ID of ServiceNow Flow (set if workflowType is 'flow')
  }
}
