# Ansible: Morpheus API

Ansible automation for the HPE Morpheus appliance, complementing the Terraform
module in [`../TF`](../TF).

The token-retrieval logic lives in `tasks/get_morpheus_token.yml` and is shared
(via `import_tasks`) by the playbooks below.

## `get_morpheus_token.yml`

Obtains a Morpheus API OAuth token from a username and password, using the same
password-grant flow as the Terraform helper scripts (`POST /oauth/token` with the
built-in `morph-api` client). The token is registered as the `morpheus_token`
fact so later plays/tasks can reuse it as `Authorization: BEARER {{ morpheus_token }}`.

### Requirements

- Ansible (`ansible-core`) on the control machine.
- Network access to the appliance.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `morpheus_url` | yes | – | Base URL of the appliance, e.g. `https://morpheus.example.com` |
| `morpheus_username` | yes | – | Login username (e.g. `johnl`, or `subtenant\user`) |
| `morpheus_password` | yes | – | Login password |
| `morpheus_validate_certs` | no | `true` | Verify the appliance TLS cert; set `false` for self-signed/lab appliances |
| `morpheus_scope` | no | `write` | OAuth scope |

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

1. `GET /api/clouds` — all clouds visible to the authenticated user.
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
