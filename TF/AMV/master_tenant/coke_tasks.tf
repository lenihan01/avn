resource "hpe_morpheus_task_shell_script" "coke_shell_task_1" {
  name                = "Coke Shell Task 1"
  code                = "cokeshelltask1"
  labels              = ["coke", "terraform"]
  source_type         = "local"
  script_content      = <<EOF
  echo "Coke task testing"
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

