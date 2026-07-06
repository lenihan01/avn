data "hpe_morpheus_node_type" "ubuntu_2404_vmware" {
  name     = "Ubuntu 24.04"
  provider = hpe.master-tenant
}
