# Provider bug: VMware cloud inventory level is not applied

## Summary

Setting `import_existing_vms = "basic"` on a `hpe_morpheus_cloud` (VMware) does
**not** enable "Inventory Existing Instances". Existing ESXi **hosts** get
inventoried, but **no VMs** are ever discovered (`serverCounts.vm` stays `0`).

- Provider: `HPE/hpe` **v1.5.0** (pinned in `versions.tf`)
- Cloud type: `vmware` (VMware vCenter)
- Symptom: hosts inventoried, VMs not (`serverCounts.vm == 0`)

## Root cause

Morpheus drives VM inventory off the **top-level** `zone.inventoryLevel`
property. The v1.5.0 provider only ever writes `inventoryLevel` into the cloud's
**nested `config` map** — it never sets the top-level property. Its SDK request
model (`AddCloudsRequestZone`) has **no top-level `inventoryLevel` field** at
all, so the provider is structurally unable to set it on create or update.

Both provider code paths confirm this:

- `cloud_create.go` (generic config path): `configDataMap["inventoryLevel"] = plan.ImportExistingVms.ValueString()`
- `cloud_create.go` (structured `config_vmware` path): `config.InventoryLevel = plan.ImportExistingVms.ValueStringPointer()`
- `cloud_update.go`: `updateCloud.Config["inventoryLevel"] = plan.ImportExistingVms.ValueString()`

All three write into **config**, never the top-level zone field.

## Evidence

`GET /api/zones/9` (Coke VMWare Cloud 1) after apply shows the mismatch:

```jsonc
{
  "inventoryLevel": "off",                 // <-- top-level: what Morpheus honors
  "config": {
    "inventoryLevel": "basic"              // <-- where the provider wrote it
  },
  "stats": {
    "serverCounts": { "host": 4, "hypervisor": 4, "vm": 0 }   // hosts yes, VMs no
  }
}
```

A direct PUT of the top-level property works:

```bash
curl -sk -X PUT -H "Authorization: BEARER $TOKEN" -H "Content-Type: application/json" \
  "$URL/api/zones/9" -d '{"zone":{"inventoryLevel":"basic"}}' \
  | jq '.zone | {name, inventoryLevel}'
# => { "name": "Coke VMWare Cloud 1", "inventoryLevel": "basic" }
```

After the next cloud sync (~5 min) the VM count climbs above 0.

## Workaround (in this module)

Because the provider cannot set the top-level property, a post-apply API call
sets it directly:

- `set_inventory_level.sh` — authenticates as the master admin and idempotently
  PUTs `{"zone":{"inventoryLevel":"<level>"}}` to `/api/zones/<id>` (skips when
  already at the desired level; validates level is `off`/`basic`/`full`).
- `terraform_data.vmware_inventory_level` in `clouds.tf` — `for_each` over the
  VMware clouds, runs the script via a `local-exec` provisioner keyed on the
  cloud id and desired level. Mirrors the `bootstrap_admin.sh` pattern.

`INVENTORY_LEVEL` in the `terraform_data` resource must be kept in sync with the
cloud's `import_existing_vms` value (currently `"basic"`).

## Inventory level values

`off` (no VM inventory), `basic` (inventory only, no agent), `full` (inventory
plus agent install on discovered VMs).

## Fix upstream

Report to HPE: for VMware (and likely all cloud types) the provider should set
the **top-level** `zone.inventoryLevel` on create/update, not just
`config.inventoryLevel`. This requires the SDK request model
(`AddCloudsRequestZone`) to expose a top-level `inventoryLevel` field.
