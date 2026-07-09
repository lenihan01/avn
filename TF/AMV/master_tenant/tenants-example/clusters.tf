###############################################################################
# HVM cluster in the Coke-Finance sub-tenant
#
# Provisions an HVM cluster from two existing hosts (added via ssh_hosts) into
# the Coke-Finance "Coke Finance HVM Cloud 1" (clouds.tf) and the existing "Coke
# HVM Group" (hpe_morpheus_group.coke_finance, also in Coke-Finance). Created
# through the hpe.coke_finance provider so the cluster belongs to Coke-Finance,
# where its group and cloud live. depends_on defers creation until the
# Coke-Finance bootstrap admin exists (for auth).
#
# The cluster layout and service plan are global library objects, resolved by
# name via the master provider.
###############################################################################

# The cluster layout is resolved by name via the master provider. In provider
# v1.5.0 the cluster-layout data source is named hpe_morpheus_cluster_type (it
# was renamed to hpe_morpheus_cluster_layout in a later release). Its id feeds
# the cluster's layout_id. cluster_type_code is set automatically by the provider
# because config_hvm (a static config) is used.
data "hpe_morpheus_cluster_type" "hvm_cluster" {
  name = "HVM 1.3 Cluster on HVM/Ubuntu 24.04"
}

data "hpe_morpheus_service_plan" "manual" {
  name                = "Default Manual"
  provision_type_code = "manual"
}

resource "hpe_morpheus_cluster" "coke_hvm" {
  provider = hpe.coke_finance

  name        = "Coke HVM Cluster 1"
  description = "Coke HVM Cluster 1"
  cloud_id    = hpe_morpheus_cloud.coke_finance_hvm.id
  group_id    = hpe_morpheus_group.coke_finance.id
  layout_id   = data.hpe_morpheus_cluster_type.hvm_cluster.id

  labels = ["terraform", "coke", "hvm"]

  config_hvm = {
    create_user       = false
    dynamic_placement = false
    cpu_arch          = "x86_64"
    cpu_model         = "host-model"
    power_policy      = "balanced"
  }

  server = {
    service_plan_id = data.hpe_morpheus_service_plan.manual.id

    ssh_port                 = 22
    ssh_username             = "ubuntu"
    ssh_password_wo          = var.coke_finance_hvm_ssh_password
    ssh_password_wo_version  = 1
    management_net_interface = "eth0"

    # Existing hosts added to the cluster.
    ssh_hosts = [
      { name = "360ubuntu3", ip = "172.16.0.83" },
      { name = "360ubuntu4", ip = "172.16.0.84" },
    ]

    visibility = "private"
  }

  depends_on = [terraform_data.coke_subtenant_admin]
}
