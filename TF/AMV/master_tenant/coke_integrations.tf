# Coke Ansible Integration 1
resource "hpe_morpheus_integration_ansible" "coke_ansible_integration_1" {
  name                          = "Coke Ansible Integration 1 (Wordpress)"
  enabled                       = true
  url                           = "https://github.com/santosh-hpe/wordpress.git"
  default_branch                = "master"
  playbooks_path                = "/"
  roles_path                    = "roles"
  group_variables_path          = "group_vars"
  host_variables_path           = "/"
  enable_ansible_galaxy_install = true
  enable_verbose_logging        = true
  enable_agent_command_bus      = true
  enable_git_caching            = false 
}
