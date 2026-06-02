resource "hpe_morpheus_cloud" "pepsi_vmware_1" {
  count     = 1 
  name      = "Coke VMWare Cloud 1"
  tenant_id = hpe_morpheus_tenant.pepsi-master-tenant.id 
  group_id  = 1

  code             = "pepsivmwarecloud1"
  external_id      = "pepsivmwarecloud1"
  labels           = ["aLabel1", "aLabel2"]
  data_center_name = "ALF"
  enabled          = true
  location         = "AMV"
  visibility       = "private"

  agent_install_mode       = "ssh"
  appliance_url            = ""
  auto_recover_power_state = true
  import_existing_vms      = "off"

  costing_mode  = "costing"
  guidance_mode = "off"

  security_mode = "off"

  keyboard_layout = "us"

  config_vmware = {
    api_url                       = "https://172.16.36.246"
    api_version                   = "7.0"
    datacenter                    = "Datacenter_2"
    cluster                       = "Cluster_2"
    username                      = "administrator@vsphere.local"
    password                      = "<redacted>"
    certificate_provider          = "internal"
    enable_network_type_selection = false
  }
}
