resource "hpe_morpheus_cluster" "example_hvm" {
  count       = 0
  name        = "Coke HVM Cluster 1"
  provider    = hpe.coke-master-tenant
  description = "Coke HVM Cluster 1"
  cloud_id    = hpe_morpheus_cloud.coke_vmware_1.id 
  group_id    = hpe_morpheus_group.coke_master_tenant_group_1.id 
  layout_id   = data.hpe_morpheus_instance_type_layout.hvm.id 

  labels = [
    "terraform",
    "coke",
    "layout",
    "example",
  ]

  config_hvm = {
    create_user       = false
    dynamic_placement = false
    cpu_arch          = "x86_64"
    cpu_model         = "host-model"
    power_policy      = "default"
  }

  server = {
    service_plan_id = 1

    ssh_port                 = 22
    ssh_username             = "user"
    ssh_key_pair_id          = 1
    management_net_interface = "eth0"

    ssh_hosts = [
      {
        name = "host1"
        ip   = "10.0.0.1"
      },
      {
        name = "host2"
        ip   = "10.0.0.2"
      },
      {
        name = "host3"
        ip   = "10.0.0.3"
      }
    ]

    visibility = "private"

    tags = [
      {
        name  = "source"
        value = "terraform"
      },
      {
        name  = "environment"
        value = "example"
      },
    ]
  }
}
