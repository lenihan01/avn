data "hpe_morpheus_node_type" "ubuntu_2404_vmware" {
  id       = 365
  name     = "Ubuntu 24.04"
  provider = hpe.master-tenant
}
