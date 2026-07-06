resource "hpe_morpheus_task_shell_script" "coke_shell_task_1" {
  name                = "Coke Shell Task 1"
  code                = "cokeshelltask1"
  labels              = ["coke", "terraform"]
  source_type         = "local"
  script_content      = <<EOF
  echo "Coke task testing"
  hostname -a 
EOF
  sudo                = true
  retryable           = true
  retry_count         = 1
  retry_delay_seconds = 10
  allow_custom_config = true
#  visibility          = "public"
  provider = hpe.coke-master-tenant
  depends_on = [
    hpe_morpheus_tenant.coke-master-tenant
  ]
}

resource "hpe_morpheus_task_ansible_playbook" "wordpress_ubuntu" {
  name                = "Wordpress Ubuntu"
  code                = "wordpressubuntu"
  labels              = ["coke", "terraform", "wordpress"]
  ansible_repo_id     = hpe_morpheus_integration_ansible.coke_ansible_integration_1.id 
  git_ref             = ""
  playbook            = "wordpress_ub.yml"
  tags                = ""
  skip_tags           = ""
  command_options     = ""
  execute_target      = "resource"
  retryable           = false 
  retry_count         = 5 
  retry_delay_seconds = 10
  allow_custom_config = false 
  provider = hpe.coke-master-tenant
}
