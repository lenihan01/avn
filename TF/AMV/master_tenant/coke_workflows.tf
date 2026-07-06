resource "hpe_morpheus_workflow_provisioning" "wordpress_workflow" {
  name        = "Wordpress workflow"
  description = "Wordpress Workflow"
  labels      = ["demo", "terraform"]
  platform    = "all"
  visibility  = "private"
  task        = [hpe_morpheus_task_ansible_playbook.wordpress_ubuntu.id]
}
