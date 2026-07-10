# Two-tenant Morpheus example (Coke / Pepsi)

Self-contained Terraform configuration that stands up a small multi-tenant
[HPE Morpheus](https://www.hpe.com/) environment on a single appliance using the
`HPE/hpe` provider. It creates two tenants (**Coke** and **Pepsi**), a
Coke-owned sub-tenant (**Coke-Finance**), and — per tenant — roles, a bootstrap
admin, standard users, an infrastructure group, a VMware cloud, lifecycle
policies, tasks, and (for Coke) an instance type, Ansible integration and
provisioning workflow.

Everything is driven from the master tenant. Sub-tenant objects that have no
`tenant_id` field are created through per-tenant provider aliases that
authenticate as each tenant's bootstrap admin.

---

## Requirements

| Requirement | Version / notes |
|---|---|
| Terraform | **>= 1.11.0** (required for the write-only `password_wo` user attribute) |
| Provider `HPE/hpe` | **pinned to 1.5.0** (`versions.tf`) |
| Provider `hashicorp/external` | **>= 2.3.0** |
| `curl` and `jq` | Must be on the machine running Terraform — several workarounds shell out to the Morpheus API via `local-exec` |
| `bash` | The helper scripts are `bash` scripts |
| A Morpheus appliance | Reachable over HTTPS, with **master-tenant admin** credentials |
| A vCenter (optional) | For the per-tenant VMware clouds to actually connect |

> The provider is intentionally pinned to **1.5.0**. Several resources/data
> sources behave differently on other versions; validate against 1.5.0 before
> bumping.

---

## Files

### Terraform configuration

| File | Purpose |
|---|---|
| `versions.tf` | Terraform & provider version constraints (`hpe` 1.5.0, `external` >= 2.3.0). |
| `providers.tf` | The master `hpe` provider plus per-tenant aliases (`hpe.coke`, `hpe.pepsi`, `hpe.coke_finance`) that log in as each tenant's bootstrap admin (`subdomain\username`). |
| `variables.tf` | All input variables (34 of them) — appliance connection, tenant admin creds, cloud connection details, and the various id/toggle inputs. |
| `locals.tf` | Core data structures everything fans out from: the `tenants` map, `coke_subtenants`, the role feature-permission ceiling, per-tenant cloud config, and derived creds. Add a tenant here to scale the whole module. |
| `roles.tf` | The shared `Base Role` (also the tenant permission ceiling), the multitenant `tenant_user` and `tenant_admin` roles. |
| `tenants.tf` | The `Coke`/`Pepsi` tenants (master provider) and the `Coke-Finance` sub-tenant (created through `hpe.coke`). |
| `users.tf` | Bootstrap admins (created via the API — see `bootstrap_admin.sh`) and the standard per-tenant users (`coke_user*`, `pepsi_user*`), assigned tenant-local role ids resolved by `hpe_morpheus_role` data sources. |
| `clouds.tf` | Per-tenant infrastructure groups + VMware clouds, the Pepsi bare-metal cloud (gated on plugin availability), the Coke-Finance HVM cloud (toggle), and `terraform_data.vmware_inventory_level`. |
| `clusters.tf` | The Coke-Finance HVM cluster (gated by `var.create_coke_finance_hvm`). |
| `instance_types.tf` | Coke library instance type + layout (references a VMware node type by id). |
| `integrations.tf` | Coke Ansible (git) integration. |
| `tasks.tf` | Per-tenant shell-script task. |
| `workflows.tf` | Coke provisioning workflow that runs the Ansible task. |
| `policies.tf` | Per-tenant instance-expiration lifecycle policies. |
| `settings.tf` | Appliance-wide cloud-init provisioning credentials (set via `set_provisioning_settings.sh`). |
| `terraform.tfvars.example` | Template for your real `terraform.tfvars` (see below). |

### Helper scripts (`local-exec`)

These exist to work around provider bugs/limitations (see **Known provider
issues**). Each authenticates as the master admin and calls the Morpheus API;
all are idempotent.

| Script | Purpose |
|---|---|
| `bootstrap_admin.sh` | Idempotently creates a tenant's first (bootstrap) admin user via the API, optionally setting Linux/Windows guest credentials. |
| `set_inventory_level.sh` | PUTs the **top-level** `zone.inventoryLevel` on a VMware cloud (the provider only writes it into nested config). |
| `set_provisioning_settings.sh` | PUTs the cloud-init username/password to `/api/provisioning-settings` (the provider resource errors on a successful update). |
| `zone_type_present.sh` | `external` data source program: returns `{"present":"true"|"false"}` for a cloud type code, so a cloud can be gated on plugin availability. |

---

## Populating `terraform.tfvars`

1. **Copy the example:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. **Fill in real values.** At minimum you must set the appliance connection and
   every `*_password` / `change-me` placeholder. Group-by-group:

   - **Appliance connection** — `morpheus_url`, `morpheus_username` (a
     master-tenant admin), `morpheus_password`, `morpheus_insecure` (`true` to
     skip TLS verification for self-signed certs).
   - **Tenant bootstrap admins** — `coke_admin_username`/`password`,
     `pepsi_admin_username`/`password`, `coke_finance_admin_username`/`password`.
     The per-tenant providers log in as these users, so the credentials must be
     valid for the users the module creates.
   - **Standard users** — `user_password` (applied to every generated user),
     `coke_user_count`, `pepsi_user_count`.
   - **VMware clouds** — `coke_cloud_*` and `pepsi_cloud_*` (`url`, `datacenter`,
     `cluster`, `username`, `password`) pointing at your vCenter.
   - **Cloud-init defaults** — `cloudinit_username`, `cloudinit_password`.
   - **Coke Ansible integration** — `coke_ansible_url` (the public sample repo
     works with no auth); `coke_ansible_branch` is optional (defaults to
     `master`).

3. **Look up the id-typed inputs.** A few values can't be resolved by name in
   v1.5.0 and must be supplied as ids (query the API as the master admin, e.g.
   with the token in `$TOKEN` and appliance in `$URL`):

   - `ubuntu_2004_node_type_id` — the **VMware** "Ubuntu 20.04" library node
     type id (Morpheus ships ~17 with that name, one per technology):
     ```bash
     curl -sk -H "Authorization: BEARER $TOKEN" \
       "$URL/api/library/container-types?phrase=Ubuntu%2020.04&max=50" \
       | jq '.containerTypes[] | {id, name, provisionType: .provisionType.code}'
     # pick the id whose provisionType is "vmware"
     ```
   - `coke_hvm_layout_id` — only needed if you enable the HVM cluster; look up
     the **cluster layout** id (there is no data source for it):
     ```bash
     curl -sk -H "Authorization: BEARER $TOKEN" \
       "$URL/api/library/cluster-layouts?phrase=HVM" \
       | jq '.clusterLayouts[] | {id, name}'
     ```

4. **Optional toggles / defaults** (safe to leave as-is):
   - `create_coke_finance_hvm` (`false`) — set `true` to create the Coke-Finance
     HVM cloud + cluster. Requires `coke_hvm_layout_id`,
     `coke_finance_hvm_ssh_password`, and a valid
     `coke_hvm_management_net_interface` (default `ens160`).
   - `pepsi_baremetal_ilo_username`/`password` — inline iLO creds for the Pepsi
     bare-metal cloud; leave empty to create it without them. (The bare-metal
     cloud is only created when the `hpe-baremetal-plugin.cloud` type exists.)

---

## Usage

```bash
terraform init
terraform plan
terraform apply
```

`curl` and `jq` must be available — the bootstrap admins, VMware inventory level
and cloud-init settings are applied via `local-exec` scripts during apply.
Everything is designed to converge in a single apply (sub-tenant data sources are
deferred to apply time and depend on the bootstrap admins).

---

## Known provider issues (v1.5.0)

This module contains **4 workarounds for provider bugs** and **3 for provider
limitations**, each documented inline in the relevant file:

**Bugs**
1. `data_center_name` null → `""` (inconsistent result on update) — set
   explicitly in `clouds.tf`.
2. VMware `inventoryLevel` only written to nested config, never top-level —
   `set_inventory_level.sh`.
3. Multitenant `role_ids` inconsistent-result — `bootstrap_admin.sh` + role data
   sources (`users.tf`).
4. `hpe_morpheus_setting_provisioning` errors on a successful update —
   `set_provisioning_settings.sh` (`settings.tf`).

**Limitations**
1. `hpe_morpheus_cloud_type` hard-errors when a type is absent —
   `zone_type_present.sh` (`clouds.tf`).
2. No cluster-layout data source — `coke_hvm_layout_id` (`clusters.tf`).
3. `hpe_morpheus_node_type` errors on duplicate names —
   `ubuntu_2004_node_type_id` (`instance_types.tf`).

---

## Multi-tenant caveat: node-type images must be visible to the sub-tenant

Creating the Coke instance type and its layout is not enough for **coke-admin**
to actually provision from it. When a sub-tenant opens the *Add Instance* wizard,
Morpheus hides any layout whose node type's backing **virtual image** the tenant
cannot see, and shows:

> No layouts are available for this configuration

The stock VMware **"Ubuntu 20.04"** node type (what `var.ubuntu_2004_node_type_id`
typically points at) is bound to a Morpheus OS-catalog image
(`Morpheus Ubuntu 20.04 <date>`) that is a **locked system image**
(`systemImage: true`, `visibility: "private"`). It is visible only to the master
tenant, and its visibility **cannot be changed even by the master account** — the
API returns *"Only the master account can edit this particular virtual image."*
So sub-tenants can never use it.

To let a sub-tenant provision, bind the node type to an image the tenant can
access:

- **Sync from vCenter** — keep an Ubuntu 20.04 VM **template** in the vCenter the
  tenant's cloud points at; Morpheus imports it as an editable (non-system)
  virtual image. Set it `public` (or share it to the tenant), or
- **Upload** an Ubuntu OVA/VMDK as a user image (`userUploaded: true`,
  master-owned → editable) and set it `public`.

Then point `var.ubuntu_2004_node_type_id` at a node type bound to that image.
Diagnose/confirm with (as the appropriate admin):

```bash
# Layout the wizard would use, and its node type + image:
curl -sk -H "Authorization: BEARER $TOKEN" "$URL/api/library/layouts/<LAYOUT_ID>" \
  | jq '.instanceTypeLayout | {provisionType: .provisionType.code,
      nodeTypes: [.containerTypes[]? | {id, provisionType: .provisionType.code, virtualImage}]}'

# Image usability — want visibility "public" (or the tenant in .accounts) and systemImage:false
curl -sk -H "Authorization: BEARER $TOKEN" "$URL/api/virtual-images/<IMAGE_ID>" \
  | jq '.virtualImage | {id, name, visibility, systemImage, userUploaded, accounts}'
```

Sanity check: the same instance type provisioned **from the master tenant** will
offer the layout (master can see the image), which confirms image visibility is
the only blocker. This is an appliance-side matter — the module cannot set image
visibility.

---

## Caveat: `terraform destroy` may fail on the AD identity source

If the optional Active Directory identity source is enabled
(`create_coke_identity_source = true`, `identity_sources.tf`), a
`terraform destroy` (or any destroy that removes the Coke tenant) can fail with:

> Error: 400 (Bad Request): {"success":false,"msg":"Identity source could not be
> deleted because users exist."}

Once the AD identity source has been used, Morpheus auto-creates user records for
the AD accounts that log in (or are synced). These are **not**
`hpe_morpheus_user` resources, so Terraform does not manage or remove them, and
Morpheus refuses to delete an identity source while any of its users remain. The
`HPE/hpe` provider (v1.5.0) offers **no delete-time / force-delete option** on
`hpe_morpheus_identity_source_active_directory` — its schema exposes only config
attributes — so there is nothing to override this from Terraform.

To get past it, remove the identity source from Terraform's delete path and let
the tenant deletion clean it up on the appliance (deleting a Morpheus account
cascades to its identity sources **and** users):

```bash
# Stop TF deleting the identity source directly; the tenant delete removes it.
terraform state rm 'hpe_morpheus_identity_source_active_directory.coke[0]'
terraform destroy -var-file=... # deletes the Coke tenant, which removes the source + AD users
terraform apply   -var-file=... # recreates the identity source fresh
```

Alternatively, delete the AD users first (Coke tenant → **Administration →
Users**), then the source (**Administration → Identity Sources**), or via API
`DELETE $URL/api/accounts/<TENANT_ID>/user-sources/<SOURCE_ID>`, then re-run the
destroy.

---

## Secrets & version control

`terraform.tfvars` holds credentials, so it — along with state files and the
`.terraform/` working directory — is kept out of version control by the
`.gitignore` shipped alongside this module:

```gitignore
terraform.tfvars
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
```

The helper scripts also avoid leaking secrets at runtime: the appliance password
is fed to `curl` on stdin and the API bearer token is passed from a `0600` temp
file, so neither appears in the process list (argv) during `terraform apply`.
