data "hpe_morpheus_node_type" "ubuntu_2404_vmware" {
  # Need to use ID for now, as name is not unique and there's no way to narrow the search AFAIK
  id       = 365
  name     = "Ubuntu 24.04"
  provider = hpe.master-tenant
}
