resource "hpe_morpheus_task_shell_script" "pepsi_shell_task_1" {
  name                = "Pepsi Shell Task 1"
  code                = "pepsishelltask1"
  labels              = ["pepsi", "terraform"]
  source_type         = "local"
  script_content      = <<EOF
  echo "Pepsi task testing"
  hostname -a 
EOF
  sudo                = true
  retryable           = true
  retry_count         = 1
  retry_delay_seconds = 10
  allow_custom_config = true
  #  visibility          = "public"
  provider = hpe.pepsi-master-tenant
  depends_on = [
    hpe_morpheus_tenant.pepsi-master-tenant
  ]
}

