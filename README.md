# avn — HPE Morpheus automation

Automation and examples for provisioning and managing a multi-tenant
[HPE Morpheus](https://www.hpe.com/) environment. The repository is split into
two independent, self-contained areas:

| Directory | What it is |
|---|---|
| [`TF/`](TF/) | A **Terraform module** that stands up a complete two-tenant (Coke / Pepsi) Morpheus example — tenants, roles, users, VMware clouds, policies, tasks, workflows and instance types — using the `HPE/hpe` provider. This is the primary, declarative way to reproduce the environment. |
| [`ansible/`](ansible/) | **Ansible playbooks** that call the Morpheus REST API — obtain an API token from a username/password, and list clouds and the instances in each. See [`ansible/README.md`](ansible/README.md). |
| [`API/`](API/) | A library of **standalone `bash` + `curl` scripts** that exercise the Morpheus REST API directly. Useful for exploration, one-off operations, and understanding the API calls that back the Terraform workarounds. |

## `TF/` — Terraform module

The recommended entry point. It builds the whole environment in a single
`terraform apply` and encapsulates several workarounds for known provider
bugs/limitations (documented inline in the module).

See [`TF/README.md`](TF/README.md) for the full file-by-file description,
requirements (Terraform >= 1.11.0, `HPE/hpe` provider 1.5.0, `curl` + `jq`), and
how to populate `terraform.tfvars` from the supplied example.

## `ansible/` — Morpheus API playbooks

Ansible playbooks that talk to the Morpheus REST API from `localhost`:

- `get_morpheus_token.yml` — obtain an API OAuth token from a username/password.
- `list_clouds_and_instances.yml` — obtain a token, then list every cloud and
  the instances in each.

The shared token-retrieval tasks live in `ansible/tasks/get_morpheus_token.yml`.
Only the bundled `ansible.builtin` modules are used (no extra collections). See
[`ansible/README.md`](ansible/README.md) for dependencies, variables and usage.

## `API/` — raw REST API scripts

A set of small scripts grouped by theme, each calling a single Morpheus endpoint:

| Group | Focus |
|---|---|
| `1_infrastructure_as_code_p3/` | Tenants, clouds and cloud types (create / get / delete). |
| `2_api_completeness_p4/` | Instances and catalog items. |
| `7_lifecycle_management_p5/` | Instance history, audit and health logs, failed/tagged instances. |
| `8_reliability_and_integrity_p6/` | Service plans, provision types, instance resize. |
| `9_availability_p6/` | Instance edit / availability operations. |
| `Miscellaneous/` | Tokens, users, clients, policies, `whoami`. |
| `all_in_one/` | Combined end-to-end example (token + cloud). |
| `lib/functions.sh` | Shared helper (HTTP response-code handling). |

**Usage:** the scripts read the appliance connection from environment variables
`URL`, `USER` and `PASSWORD`, obtain an OAuth token, and call the API with
`curl`. Requires `bash` and `curl`; run them from within their own directory so
the relative `../lib/functions.sh` include resolves.

> Note: these API scripts are exploratory helpers — unlike the `TF/` module they
> do not redact credentials from the process command line, so run them only on a
> trusted, non-shared host.

## Requirements

- A reachable HPE Morpheus appliance and a master-tenant admin account.
- `TF/`: Terraform >= 1.11.0, the `HPE/hpe` (1.5.0) and `hashicorp/external`
  providers, plus `curl` and `jq`.
- `ansible/`: `ansible-core` (2.11+) and Python 3 on the control machine; only
  the bundled `ansible.builtin` modules (no extra collections).
- `API/`: `bash` and `curl`.
