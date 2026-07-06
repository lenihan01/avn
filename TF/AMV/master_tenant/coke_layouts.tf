data "hpe_morpheus_instance_type_layout" "hvm" {
  name                        = "Single HVM"
  provider                    = hpe.master-tenant
}

#resource "hpe_morpheus_instance_type_layout" "ubuntu_wordpress_vmware_layout" {
#  instance_type_id = hpe_morpheus_instance_type.wordpress_ubuntu.id
#  name             = "Ubuntu Wordpress VMWare Layout"
#  labels           = ["coke", "layout", "terraform"]
#  version          = "1.0"
#  technology       = "vmware"
#  node_type_ids    = [data.hpe_morpheus_node_type.ubuntu_2404_vmware.id]
#  workflow_id      = hpe_morpheus_workflow_provisioning.wordpress_workflow.id
#}
