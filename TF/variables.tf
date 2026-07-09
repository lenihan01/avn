variable "morpheus_url" {
  type        = string
  description = "Base URL of the Morpheus appliance, e.g. https://morpheus.example.local"
}

variable "morpheus_username" {
  type        = string
  description = "Master tenant username used to authenticate to Morpheus."
}

variable "morpheus_password" {
  type        = string
  description = "Master tenant password used to authenticate to Morpheus."
  sensitive   = true
}

variable "morpheus_insecure" {
  type        = bool
  description = "Skip TLS certificate verification (useful for lab appliances with self-signed certs)."
  default     = false
}

variable "coke_admin_username" {
  type        = string
  description = "Username for the bootstrap administrator created via the Morpheus API in the Coke tenant (users.tf). The Coke sub-tenant provider authenticates as this user."
}

variable "coke_admin_password" {
  type        = string
  description = "Password for the Coke tenant bootstrap administrator (created via the Morpheus API in users.tf)."
  sensitive   = true
}

variable "pepsi_admin_username" {
  type        = string
  description = "Username for the bootstrap administrator created via the Morpheus API in the Pepsi tenant (users.tf). The Pepsi sub-tenant provider authenticates as this user."
}

variable "pepsi_admin_password" {
  type        = string
  description = "Password for the Pepsi tenant bootstrap administrator (created via the Morpheus API in users.tf)."
  sensitive   = true
}

variable "coke_finance_admin_username" {
  type        = string
  description = "Username for the bootstrap administrator created via the Morpheus API in the Coke-Finance sub-tenant (users.tf), following the same pattern as the Coke tenant admin."
}

variable "coke_finance_admin_password" {
  type        = string
  description = "Password for the Coke-Finance sub-tenant bootstrap administrator (created via the Morpheus API in users.tf)."
  sensitive   = true
}

variable "coke_finance_hvm_ssh_password" {
  type        = string
  description = "SSH password for the existing hosts added to the Coke HVM Cluster (clusters.tf). Applied via the write-only ssh_password_wo field."
  sensitive   = true
}

variable "create_coke_finance_hvm" {
  type        = bool
  description = "Whether to create the Coke Finance HVM Cloud 1 (clouds.tf) and its dependent HVM cluster (clusters.tf). Defaults to false; both are disabled unless set true."
  default     = false
}

variable "coke_hvm_layout_id" {
  type        = number
  description = "ID of the cluster layout used for the Coke HVM Cluster (clusters.tf), e.g. \"HVM 1.3 Cluster on HVM/Ubuntu 24.04\". The pinned provider (v1.5.0) has no cluster-layout data source, so supply the id explicitly. Look it up with: GET /api/library/cluster-layouts?phrase=HVM."
}

variable "coke_hvm_management_net_interface" {
  type        = string
  description = "Name of the management network interface on the Coke HVM Cluster hosts (clusters.tf), e.g. \"ens160\". Must exist on every ssh_host or the cluster create fails connectivity verification."
  default     = "ens160"
}

variable "pepsi_baremetal_ilo_username" {
  type        = string
  description = "iLO username for the Pepsi bare-metal (BMaaS) cloud (clouds.tf). Optional; leave empty to create the cloud without inline iLO credentials."
  default     = ""
  sensitive   = true
}

variable "pepsi_baremetal_ilo_password" {
  type        = string
  description = "iLO password for the Pepsi bare-metal (BMaaS) cloud (clouds.tf). Optional; leave empty to create the cloud without inline iLO credentials."
  default     = ""
  sensitive   = true
}

variable "user_password" {
  type        = string
  description = "Password assigned to every generated tenant user (coke_user*/pepsi_user*). Use per-user secrets in production."
  sensitive   = true
}

variable "coke_user_count" {
  type        = number
  description = "Number of standard users to create in the Coke tenant (coke_user[0..n-1])."
  default     = 3
}

variable "pepsi_user_count" {
  type        = number
  description = "Number of standard users to create in the Pepsi tenant (pepsi_user[0..n-1])."
  default     = 5
}

# --- VMware (vCenter) cloud settings -----------------------------------------
# One infrastructure group and one VMware cloud are created per tenant
# (clouds.tf). These mirror the per-tenant cloud variables in the parent module
# (coke_clouds.tf/pepsi_clouds.tf).

# Coke VMware cloud
variable "coke_cloud_url" {
  type        = string
  description = "vCenter API URL for the Coke VMware cloud, e.g. https://vcenter.example.local"
}

variable "coke_cloud_datacenter" {
  type        = string
  description = "vCenter datacenter for the Coke VMware cloud."
}

variable "coke_cloud_cluster" {
  type        = string
  description = "vCenter cluster for the Coke VMware cloud."
}

variable "coke_cloud_username" {
  type        = string
  description = "vCenter username for the Coke VMware cloud."
  default     = "administrator@vsphere.local"
}

variable "coke_cloud_password" {
  type        = string
  description = "vCenter password for the Coke VMware cloud."
  sensitive   = true
}

# Pepsi VMware cloud
variable "pepsi_cloud_url" {
  type        = string
  description = "vCenter API URL for the Pepsi VMware cloud, e.g. https://vcenter.example.local"
}

variable "pepsi_cloud_datacenter" {
  type        = string
  description = "vCenter datacenter for the Pepsi VMware cloud."
}

variable "pepsi_cloud_cluster" {
  type        = string
  description = "vCenter cluster for the Pepsi VMware cloud."
}

variable "pepsi_cloud_username" {
  type        = string
  description = "vCenter username for the Pepsi VMware cloud."
  default     = "administrator@vsphere.local"
}

variable "pepsi_cloud_password" {
  type        = string
  description = "vCenter password for the Pepsi VMware cloud."
  sensitive   = true
}

# --- Ansible integration (Coke tenant) ---------------------------------------
# integrations.tf creates one Ansible (git) integration inside the Coke
# sub-tenant. Set coke_ansible_url to the git repository to attach (see
# terraform.tfvars.example); for a private repo also add auth on the resource.
variable "coke_ansible_url" {
  type        = string
  description = "Git repository URL for the Coke tenant's Ansible integration."
}

variable "coke_ansible_branch" {
  type        = string
  description = "Default branch of the Coke tenant's Ansible repository."
  default     = "master"
}

# --- Instance type layout (Coke tenant) --------------------------------------
# instance_types.tf adds a VMware layout ("Coke Ubuntu 20.04 Layout") to the Coke
# "coke ubuntu wordpress" instance type, bound to the VMware "Ubuntu 20.04" node
# type. Morpheus ships one "Ubuntu 20.04" node type per technology, so it must be
# selected by id (the by-name lookup is ambiguous). Find the VMware one's id on
# the appliance, e.g.:
#
#   TOKEN=$(curl -sk "https://<appliance>/oauth/token?grant_type=password&scope=write&client_id=morph-api" \
#     -d "username=<admin>&password=<pw>" | jq -r .access_token)
#   curl -sk "https://<appliance>/api/library/container-types?max=500&phrase=Ubuntu%2020.04" \
#     -H "Authorization: Bearer $TOKEN" \
#     | jq -r '.containerTypes[] | select(.name=="Ubuntu 20.04") | "\(.id)\t\(.provisionType.code)"'
#
# then use the id of the row whose provision type code is "vmware".
variable "ubuntu_2004_node_type_id" {
  type        = number
  description = "Id of the VMware 'Ubuntu 20.04' node type to bind to the Ubuntu 20.04 layout (instance_types.tf). Resolve by id -- the name matches one node type per technology. See the comment above for how to find it."
}

# --- Appliance provisioning settings (settings.tf) ---------------------------
# Default cloud-init credentials Morpheus injects into provisioned Linux
# instances, set via hpe_morpheus_setting_provisioning.
variable "cloudinit_username" {
  type        = string
  description = "Default cloud-init username applied to provisioned instances (settings.tf / hpe_morpheus_setting_provisioning)."
}

variable "cloudinit_password" {
  type        = string
  description = "Default cloud-init password applied to provisioned instances (settings.tf / hpe_morpheus_setting_provisioning)."
  sensitive   = true
}
