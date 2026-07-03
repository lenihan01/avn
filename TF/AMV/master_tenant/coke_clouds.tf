resource "hpe_morpheus_cloud" "coke_vmware_1" {
  name      = "Coke VMWare Cloud 1"
  tenant_id = hpe_morpheus_tenant.coke-master-tenant.id 
  group_id  = 1

  provider  = hpe.master-tenant
  code             = "cokevmwarecloud1"
  external_id      = "cokevmwarecloud1"
  labels           = ["aLabel1", "aLabel2"]
  data_center_name = "AMV"
  enabled          = true
  location         = "AMV"
  visibility       = "private"

  agent_install_mode       = "ssh"
  appliance_url            = "https://emorph.can.cs8.local"
  auto_recover_power_state = true
  import_existing_vms      = "off"

  costing_mode  = "costing"
  guidance_mode = "off"

  security_mode = "off"

  keyboard_layout = "us"

#  config_vmware = {
#    api_url                       = "https://vcenter9.cs8.local"
#    api_version                   = "7.0"
#    datacenter                    = "DC9"
#    cluster                       = "CL9"
#    username                      = "administrator@vsphere.local"
#    password                      = "<redacted>"
#    certificate_provider          = "internal"
#    enable_network_type_selection = false
#  }

  cloud_type_code = "vmware"
  config = {
    apiUrl                       = "https://vcenter9.cs8.local"
    apiVersion                   = "7.0"
    datacenter                    = "DC9"
    cluster                       = "CL9"
    username                      = "administrator@vsphere.local"
    password                      = var.coke_cloud_password 
    certificateProvider          = "internal"
#    enable_network_type_selection = false
  }
}
