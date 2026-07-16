# API — Morpheus REST API bash/curl scripts

A library of standalone **`bash` + `curl`** scripts that exercise the
[HPE Morpheus](https://www.hpe.com/) REST API directly. They are useful for
exploration, one-off operations, and understanding the raw API calls that back
the Terraform module in [`../TF/`](../TF/).

Each script is a thin, self-contained wrapper around a single API endpoint: it
validates its required environment variables, prints the request it is about to
make, and issues a `curl` call (piping JSON responses through `jq`).

## Requirements

- `bash`, [`curl`](https://curl.se/) and [`jq`](https://stedolan.github.io/jq/).
- Network access to a Morpheus appliance (scripts use `--insecure`, so they
  tolerate self-signed certificates).
- A Morpheus user account (for token retrieval) or an existing bearer token.

## Conventions

All scripts share the same shape:

1. A copyright header, then `#!/bin/bash` and `set` flags.
2. `. ../lib/functions.sh` — sourced from the sibling [`lib/`](lib/) directory,
   so **scripts are intended to be run from inside their own subdirectory**
   (e.g. `cd 1_infrastructure_as_code_p3&& ./5_get_all_clouds.sh`).
3. A guard that exits non-zero if a required environment variable is unset.
4. `operation` / `protocol` / `endpoint` / `args` variables that build the URL.
5. The `curl` call itself.

> **Note on redaction.** For safety, the committed scripts show
> `--header "authorization: ******"` and `--data "******"` in place of the real
> bearer token and password payloads. Supply your own credentials (typically
> `--header "authorization: BEARER ${TOKEN}"`) when running them for real.

### Environment variables

| Variable | Used by | Meaning |
|---|---|---|
| `URL` | all | Appliance host, **without** scheme (e.g. `morpheus.example.com`); scripts prepend `https://`. |
| `TOKEN` | all `/api/*` scripts | OAuth bearer token (obtain via the token scripts below). |
| `USER` | token scripts | Morpheus username (for password-grant token retrieval). |
| `PASSWORD` | token scripts | Morpheus password. |
| `ID` | single-resource GET/DELETE/PUT scripts | The id of the target resource (tenant, cloud, instance, catalog item, policy…). |
| `INSTANCE_ID`, `PLAN_ID` | `resize_instance.sh` | Instance to resize and the target service-plan id. |

### Getting a token

Most scripts need `TOKEN`. Retrieve one with the password grant and export it:

```bash
export URL="morpheus.example.com"
export USER="admin"
export PASSWORD="…"
cd Miscellaneous
export TOKEN=$(./2_get_token.sh | jq -r .access_token)
```

## Shared library

- **[`lib/functions.sh`](lib/functions.sh)** — sourced by every script. Provides
  `check_response_code`, which maps an HTTP status code (200/302/400/401/403/404/500/503)
  to a human-readable message and an appropriate exit status.

## Scripts by area

Numeric prefixes indicate a suggested run order within a directory (e.g. create
→ get → delete). The `p3`–`p6` suffixes group the directories by demo phase.

### `1_infrastructure_as_code_p3/` — tenants & clouds

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `0_get_all_tenants.sh` | GET | `/api/accounts` | — | List all tenants (accounts). |
| `1_create_tenant.sh` | POST | `/api/accounts` | — | Create a tenant. |
| `2_get_all_tenants.sh` | GET | `/api/accounts` | — | List tenants (re-check after create). |
| `4_get_all_tenants.sh` | GET | `/api/accounts` | — | List tenants (re-check after delete). |
| `get_a_tenant.sh` | GET | `/api/accounts/{ID}` | `ID` | Get a single tenant. |
| `99_delete_tenant.sh` | DELETE | `/api/accounts/{ID}` | `ID` | Delete a tenant. |
| `5_get_all_clouds.sh` | GET | `/api/zones` | — | List all clouds (zones). |
| `6_create_cloud.sh` | POST | `/api/zones` | — | Create a VMware/vSphere cloud. |
| `7_get_all_clouds.sh` | GET | `/api/zones` | — | List clouds (re-check after create). |
| `8_delete_cloud.sh` | DELETE | `/api/zones/{ID}` | `ID` | Delete a cloud (release IPs/EIPs, force). |
| `9_get_all_clouds.sh` | GET | `/api/zones` | — | List clouds (re-check after delete). |
| `get_a_cloud.sh` | GET | `/api/zones/{ID}` | `ID` | Get a single cloud. |
| `get_all_cloud_types.sh` | GET | `/api/zone-types` | — | List all cloud (zone) types. |
| `get_a_cloud_type.sh` | GET | `/api/zone-types/{ID}` | `ID` | Get a single cloud type. |

### `2_api_completeness_p4/` — instances & catalog items

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `1_create_instance.sh` | POST | `/api/instances` | — | Provision an instance. |
| `2_get_instances.sh` | GET | `/api/instances` | — | List all instances. |
| `3_get_an_instance.sh` | GET | `/api/instances/{ID}` | `ID` | Get a single instance (with details). |
| `5_delete_instance.sh` | DELETE | `/api/instances/{ID}` | `ID` | Delete an instance. |
| `6_create_catalog_item.sh` | POST | `/api/catalog-item-types` | — | Create a workflow catalog item. |
| `6b_get-catalog_items.sh` | GET | `/api/catalog-item-types` | — | List catalog item types. |
| `6c_get_a_catalog_item.sh` | GET | `/api/catalog-item-types/{ID}` | `ID` | Get a single catalog item type. |
| `7_delete_catalog_item.sh` | DELETE | `/api/catalog-item-types/{ID}` | `ID` | Delete a catalog item type. |

### `7_lifecycle_management_p5/` — monitoring & history

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `get_an_instance.sh` | GET | `/api/instances/{ID}` | `ID` | Get a single instance (with details). |
| `get_instance_history.sh` | GET | `/api/instances/{ID}/history` | `ID` | Get an instance's process/action history. |
| `4a_get_failed_instances.sh` | GET | `/api/instances?status=failed` | — | List instances in the `failed` state. |
| `4b_get_tagged_instances.sh` | GET | `/api/instances?tags.UI=1` | — | List instances by a tag filter. |
| `get_audit_logs.sh` | GET | `/api/audit` | — | Retrieve audit logs (up to 10000). |
| `get_health_logs.sh` | GET | `/api/health/logs` | — | Retrieve appliance health logs. |

### `8_reliability_and_integrity_p6/` — plans & provision types

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `0_get_all_instances.sh` | GET | `/api/instances` | — | List all instances. |
| `1_get_all_plans.sh` | GET | `/api/service-plans` | — | List all service plans. |
| `2_get_all_plans_vmware.sh` | GET | `/api/service-plans?provisionTypeId=22` | — | List service plans for VMware. |
| `get_all_provision_types.sh` | GET | `/api/provision-types` | — | List all provision types. |
| `get_all_provision_types_vmware.sh` | GET | `/api/provision-types?name=VMware` | — | List VMware provision types. |
| `resize_instance.sh` | PUT | `/api/instances/{INSTANCE_ID}/resize` | `INSTANCE_ID`, `PLAN_ID` | Resize an instance to a new plan. |

### `9_availability_p6/` — instance edits

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `get_an_instance.sh` | GET | `/api/instances/{ID}` | `ID` | Get a single instance (with details). |
| `edit_instance.sh` | PUT | `/api/instances/{ID}` | `ID` | Edit an instance (name, description, tags…). |

### `Miscellaneous/` — auth, users, policies

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `0_whoami.sh` | GET | `/api/whoami` | — | Show the identity/permissions of the current token. |
| `1_get_clients.sh` | GET | `/api/clients` | — | List OAuth API clients. |
| `2_get_token.sh` | POST | `/oauth/token` | `USER`, `PASSWORD` | Obtain a bearer token (password grant). |
| `3_get_users.sh` | GET | `/api/users` | — | List users. |
| `4_get_policies.sh` | GET | `/api/policies` | — | List policies. |
| `5_create_tag_policy.sh` | POST | `/api/policies` | — | Create a tag policy. |
| `6_delete_policy.sh` | DELETE | `/api/policies/{ID}` | `ID` | Delete a policy. |

### `all_in_one/` — end-to-end example

| Script | Method | Endpoint | Extra vars | Purpose |
|---|---|---|---|---|
| `create_token_and_cloud.sh` | POST | `/oauth/token` → `/api/zones` | `USER`, `PASSWORD` | Retrieve a token from username/password, then use it to create a cloud in one run. |

## Example

```bash
export URL="morpheus.example.com"
export USER="admin"
export PASSWORD="…"

# Get a token
cd Miscellaneous
export TOKEN=$(./2_get_token.sh | jq -r .access_token)

# List all tenants
cd ../1_infrastructure_as_code_p3
./0_get_all_tenants.sh

# Fetch one cloud by id
export ID=9
./get_a_cloud.sh
```
