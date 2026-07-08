resource "hpe_morpheus_group" "coke_master_tenant_group_1" {
  name      = "Coke Master Tenant Group 1"
  location  = "AMV"
  code      = "cmtg1"
  cloud_ids = [hpe_morpheus_cloud.coke_vmware_1.id]
  provider  = hpe.coke-master-tenant
}
