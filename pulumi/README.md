# Pulumi: Morpheus clouds & instances

A Pulumi (Python) program that lists every HPE Morpheus cloud and the instances
provisioned in each one, by calling the Morpheus REST API. It is the Pulumi
equivalent of the Ansible playbook
[`../ansible/list_clouds_and_instances.yml`](../ansible/list_clouds_and_instances.yml).

On `pulumi up` it:

1. Obtains an API OAuth token from a username + password (password-grant
   `POST /oauth/token` with the built-in `morph-api` client).
2. `GET /api/zones` — all clouds visible to the authenticated user.
3. `GET /api/instances?zoneId=<id>` — the instances in each cloud.

and exports two stack outputs:

| Output | Description |
| --- | --- |
| `clouds` | Machine-readable list of `{cloud_id, cloud_name, instances: [{id, name, status}, ...]}`. |
| `summary` | Human-readable `"<cloud> (id N) - M instance(s): [names]"` per cloud. |

> **Note:** this program does not create or manage any infrastructure — it only
> reads from the API and publishes the results as stack outputs. The API calls
> run on every `pulumi up`/`preview`.

## Dependencies

- [Pulumi CLI](https://www.pulumi.com/docs/install/).
- Python 3.8+ (Pulumi creates a virtualenv from `requirements.txt`).
- Python packages: `pulumi`, `requests` (see `requirements.txt`).
- Network (HTTPS) access from the machine running Pulumi to the appliance.

## Configuration

All settings live under the `morpheus` config namespace (mirroring the Ansible
variables):

| Key | Required | Default | Description |
| --- | --- | --- | --- |
| `morpheus:url` | yes | – | Base URL of the appliance, e.g. `https://morpheus.example.com` |
| `morpheus:username` | yes | – | Login username (e.g. `johnl`, or `subtenant\user`) |
| `morpheus:password` | yes | – | Login password — **set as a secret** (see below) |
| `morpheus:validateCerts` | no | `true` | Verify the appliance TLS cert; set `false` for self-signed/lab appliances |
| `morpheus:scope` | no | `write` | OAuth scope |

## Usage

```bash
cd pulumi

# First run only: create/select a stack.
pulumi stack init dev

# Configure the connection. Store the password as an ENCRYPTED secret.
pulumi config set        morpheus:url           https://morpheus.example.com
pulumi config set        morpheus:username      johnl
pulumi config set --secret morpheus:password    's3cret'
pulumi config set        morpheus:validateCerts false   # self-signed / lab appliance

# Fetch and publish the listing.
pulumi up

# Read the results.
pulumi stack output summary
pulumi stack output clouds   # full JSON structure
```

Pulumi manages the Python virtualenv automatically (via the `virtualenv: venv`
option in `Pulumi.yaml`); you do not need to create one yourself.

## Secrets

`morpheus:password` must be set with `pulumi config set --secret` so it is stored
encrypted in the stack's `Pulumi.<stack>.yaml`. The program reads it as a Pulumi
secret and performs the API calls inside an `Output.apply`, so the plaintext is
never written to stack state. The `clouds`/`summary` outputs contain only
non-sensitive listing data and are explicitly un-secreted so they can be read
with `pulumi stack output`.

Do **not** commit a plaintext password. See `Pulumi.dev.example.yaml` for an
example stack config.
