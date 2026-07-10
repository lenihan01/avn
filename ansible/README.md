# Ansible: Morpheus API

Ansible automation for the HPE Morpheus appliance, complementing the Terraform
module in [`../TF`](../TF).

The token-retrieval logic lives in `tasks/get_morpheus_token.yml` and is shared
(via `import_tasks`) by the playbooks below.

## Dependencies

- **Ansible** — `ansible-core` (2.11+) on the control machine. Run with
  `ansible-playbook`.
- **Python 3** — required by `ansible-core` on the control machine.
- **Collections** — none beyond the bundled `ansible.builtin` (only the
  `uri`, `assert`, `set_fact`, `fail` and `debug` modules are used, so no
  `ansible-galaxy` installs are needed).
- **Network access** — HTTPS reachability from the control machine to the
  Morpheus appliance, plus a valid Morpheus login (see Variables).

These playbooks run against `localhost` (`connection: local`) and talk to the
appliance over HTTP, so no managed hosts or inventory file are required.

## Layout

| Path | Purpose |
| --- | --- |
| `tasks/get_morpheus_token.yml` | Reusable tasks that obtain an API token and register it as the `morpheus_token` fact. Imported by both playbooks. |
| `get_morpheus_token.yml` | Playbook: obtain a token from a username + password. |
| `list_clouds_and_instances.yml` | Playbook: obtain a token, then list every cloud and the instances in each. |
| `morpheus.vars.example.yml` | Example variables file — copy, fill in, and pass with `-e @file`. |
| `.gitignore` | Keeps real credential vars files (`*.vars.yml`) out of version control. |

## Variables

All playbooks share the same variables (pass via `--extra-vars` or a vars file):

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `morpheus_url` | yes | – | Base URL of the appliance, e.g. `https://morpheus.example.com` |
| `morpheus_username` | yes | – | Login username (e.g. `johnl`, or `subtenant\user`) |
| `morpheus_password` | yes | – | Login password |
| `morpheus_validate_certs` | no | `true` | Verify the appliance TLS cert; set `false` for self-signed/lab appliances |
| `morpheus_scope` | no | `write` | OAuth scope |

## `get_morpheus_token.yml`

Obtains a Morpheus API OAuth token from a username and password, using the same
password-grant flow as the Terraform helper scripts (`POST /oauth/token` with the
built-in `morph-api` client). The token is registered as the `morpheus_token`
fact so later plays/tasks can reuse it as `Authorization: BEARER {{ morpheus_token }}`.

### Usage

Pass variables on the command line:

```bash
ansible-playbook get_morpheus_token.yml \
  -e morpheus_url=https://morpheus.example.com \
  -e morpheus_username=johnl \
  -e morpheus_password='s3cret' \
  -e morpheus_validate_certs=false
```

Or from a (private) vars file — copy the example and fill it in:

```bash
cp morpheus.vars.example.yml morpheus.vars.yml   # then edit
ansible-playbook get_morpheus_token.yml -e @morpheus.vars.yml
```

The token itself is never printed (the request, token, and `set_fact` tasks use
`no_log: true`); only its length is shown on success.

## `list_clouds_and_instances.yml`

Obtains a token (same variables as above), then lists every cloud and the
instances in each:

1. `GET /api/zones` — all clouds visible to the authenticated user.
2. `GET /api/instances?zoneId=<cloud id>` — the instances in each cloud.

Results are registered as the `morpheus_cloud_instances` fact — a list of
`{ cloud_id, cloud_name, instances: [ <instance objects> ] }` — for reuse by
later plays/tasks, and printed as a per-cloud summary of instance names. The
bearer token is never logged (the API requests use `no_log: true`).

Takes the same variables as `get_morpheus_token.yml`:

```bash
ansible-playbook list_clouds_and_instances.yml \
  -e morpheus_url=https://morpheus.example.com \
  -e morpheus_username=johnl \
  -e morpheus_password='s3cret' \
  -e morpheus_validate_certs=false

# or with a vars file:
ansible-playbook list_clouds_and_instances.yml -e @morpheus.vars.yml
```

## Secrets

Do **not** commit real credentials. Keep any vars file containing a password out
of version control (see `.gitignore`) or encrypt it with `ansible-vault`.
