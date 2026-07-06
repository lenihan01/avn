data "hpe_morpheus_node_type" "ubuntu_24.04_vmware" {
  name     = "Ubuntu 24.04"
  provider = hpe.master-tenant
}
