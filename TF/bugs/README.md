# Known problems — `HPE/hpe` Terraform provider v1.5.0

This module pins the `HPE/hpe` provider to **v1.5.0** (see `../versions.tf`).
The issues below were confirmed against the actual v1.5.0 provider source / the
`hpe-morpheus-go-sdk`, and against live appliance behaviour. Each has a
workaround already implemented in the Terraform code in `../`.

**Summary: 4 confirmed bugs + 3 provider limitations = 7 workarounds.**

---

## Confirmed bugs

### 1. VMware inventory level is never set at the top level
- **Symptom:** "Inventory existing instances" does nothing even though
  `import_existing_vms` / `inventoryLevel` is set. `GET /api/zones/<id>` shows
  top-level `inventoryLevel:"off"` while `config.inventoryLevel:"basic"`.
- **Cause:** the provider writes `inventoryLevel` only into the nested `config`
  map. Morpheus honours the **top-level** `zone.inventoryLevel`, and the SDK
  request model (`AddCloudsRequestZone`) has no such field.
- **Workaround:** `../set_inventory_level.sh` +
  `terraform_data.vmware_inventory_level` — direct
  `PUT /api/zones/<id> {"zone":{"inventoryLevel":"basic"}}` (valid values:
  `off` / `basic` / `full`).

### 2. `hpe_morpheus_setting_provisioning` fails an otherwise-successful apply
- **Symptom:** apply errors with `Not found in response: ProvisioningSettings`
  even though the setting is stored correctly.
- **Cause:** after `PUT /api/provisioning-settings` the provider asserts the
  response echoes a `provisioningSettings` object
  (`setting_provisioning.go:477-479`), but Morpheus returns only
  `{"success":true}`.
- **Workaround:** `../set_provisioning_settings.sh` +
  `terraform_data.provisioning_settings` in `../settings.tf` (replaces the
  broken resource). Body shape:
  `{"provisioningSettings":{"cloudInitUsername":...,"cloudInitPassword":...}}`.

### 3. `hpe_morpheus_user` `role_ids` — inconsistent result in multi-tenant setups
- **Symptom:** assigning a master-tenant role id to a sub-tenant user produces a
  post-apply "Provider produced inconsistent result" error.
- **Cause:** Morpheus swaps the master role id for the tenant-local id on write,
  so the value read back differs from what was planned.
- **Workaround:** bootstrap sub-tenant admins via API
  (`../bootstrap_admin.sh`); for standard users, look up tenant-local ids with
  `hpe_morpheus_role` data sources scoped to the sub-tenant (`../users.tf`).

### 4. Generic `config` map drops unknown keys and drops keys on update
- **Symptom:** VMware hypervisor console can't be enabled via
  `enable_hypervisor_console`; and even valid generic keys don't stick on cloud
  updates.
- **Cause:** the VMware key is actually `enableVnc` (`"on"`/`"off"`). The
  generic dynamic `config` map passes keys verbatim and silently drops unknown
  ones; the update path also drops all generic keys except a small allowlist
  (`applianceUrl` / `datacenterName` / `externalId` / `inventoryLevel` /
  `consoleKeymap`), so `enableVnc` only applies on cloud **create**.
- **Workaround:** set `enableVnc = "on"` in the config map (`../clouds.tf`).
  A future migration to the structured `config_vmware` block (which v1.5.0 does
  have) would make this robust across updates.

> Related: `data_center_name` null→`""` can also produce an inconsistent
> result; handled by always passing a non-null value in `../clouds.tf`.

---

## Provider limitations

### 5. `hpe_morpheus_cloud_type` hard-errors when the type is absent
- **Symptom:** the SDK throws (`found 0 Cloud Types`) instead of returning an
  empty result, so you can't conditionally gate on a cloud type's presence.
- **Workaround:** `data.external` + `../zone_type_present.sh`, which queries
  `/api/zone-types` and returns `{"present":"true"|"false"}`.

### 6. No cluster-layout data source
- **Symptom:** there's no way to look up a cluster **layout** id in Terraform;
  `hpe_morpheus_cluster_type` queries `/api/cluster-types`, not layouts.
- **Workaround:** supply `var.coke_hvm_layout_id`, looked up manually via
  `GET /api/library/cluster-layouts?phrase=HVM`.

### 7. `hpe_morpheus_node_type` errors on duplicate names
- **Symptom:** the data source errors (`found 17 node types named Ubuntu 20.04`)
  because it filters only by name/id.
- **Workaround:** supply `var.coke_ubuntu_2004_node_type_id` directly.

---

## Also missing in v1.5.0

- **No `api` persona** in `persona_permissions` (only `standard`,
  `serviceCatalog`, `vdi`), so "enable API access for all users" cannot be done
  through the provider in this version.
- **`hpe_morpheus_tenant` has no `parent` attribute**, so nested (N-Tier)
  tenants cannot be expressed in Terraform even though HPE Morpheus Enterprise
  v8.1.0+ supports True N-Tier Multi-Tenancy at the platform level. Real
  hierarchy currently requires the Morpheus API (a `local-exec`/`external`
  escape hatch).

---

## Notes

- Provider source for a specific tag can be inspected with a git worktree:
  `cd /tmp/tphpe && git worktree add -f /tmp/hpe150 v1.5.0`.
- The three helper scripts (`set_inventory_level.sh`,
  `set_provisioning_settings.sh`, `bootstrap_admin.sh`) require `curl` and `jq`
  and authenticate via `POST ${MORPH_URL}/oauth/token`
  (`client_id=morph-api`, `grant_type=password`, `scope=write`).
