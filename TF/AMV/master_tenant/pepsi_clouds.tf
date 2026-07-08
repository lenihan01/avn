resource "hpe_morpheus_cloud" "pepsi_vmware_1" {
  name      = "Pepsi VMWare Cloud 1"
  tenant_id = hpe_morpheus_tenant.pepsi-master-tenant.id
  group_id  = 1

  provider         = hpe.master-tenant
  code             = "pepsivmwarecloud1"
  external_id      = "peps1vmwarecloud1"
  labels           = ["aLabel1", "aLabel2"]
  data_center_name = "AMV"
  enabled          = true
  location         = "ALF"
  visibility       = "private"

  agent_install_mode       = "ssh"
  appliance_url            = var.master_tenant_url
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
    apiUrl                    = var.pepsi_cloud_1_url
    apiVersion                = "7.0"
    datacenter                = var.pepsi_cloud_1_dc
    cluster                   = var.pepsi_cloud_1_cluster
    username                  = "administrator@vsphere.local"
    password                  = var.pepsi_cloud_password
    certificateProvider       = "internal"
    enable_hypervisor_console = true
    #    enable_network_type_selection = false
  }
}
