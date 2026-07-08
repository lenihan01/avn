resource "hpe_morpheus_group" "pepsi_master_tenant_group_1" {
  name      = "Pepsi Master Tenant Group 1"
  location  = "ALF"
  code      = "pmtg1"
  cloud_ids = [hpe_morpheus_cloud.pepsi_vmware_1.id]
  provider  = hpe.pepsi-master-tenant
}
