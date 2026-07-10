"""List Morpheus clouds and the instances in each, via the Morpheus REST API.

This is the Pulumi (Python) equivalent of the Ansible playbook
``../ansible/list_clouds_and_instances.yml``. On ``pulumi up`` it:

  1. Obtains an API OAuth token from a username + password (password-grant
     ``POST /oauth/token`` with the built-in ``morph-api`` client -- the same
     flow used by the Terraform helper scripts and the Ansible playbooks).
  2. ``GET /api/zones`` -> all clouds visible to the authenticated user.
  3. ``GET /api/instances?zoneId=<id>`` -> the instances in each cloud.

and exports two stack outputs:

  * ``clouds`` -- a list of ``{cloud_id, cloud_name, instances: [{id, name,
    status}, ...]}`` (the machine-readable mapping), and
  * ``summary`` -- a human-readable ``"<cloud>: [<instance names>]"`` per cloud.

Configuration (namespace ``morpheus``):

  pulumi config set        morpheus:url            https://morpheus.example.com
  pulumi config set        morpheus:username       johnl
  pulumi config set --secret morpheus:password     's3cret'
  pulumi config set        morpheus:validateCerts  false   # self-signed/lab
  pulumi config set        morpheus:scope          write   # optional

The password is read as a Pulumi secret; the API calls run inside an
``Output.apply`` so the plaintext is never captured in the stack state. The
exported ``clouds``/``summary`` outputs hold only non-sensitive listing data, so
they are explicitly un-secreted to remain readable via ``pulumi stack output``.
"""

from typing import Any, Dict, List

import pulumi
import requests
import urllib3

config = pulumi.Config("morpheus")

MORPHEUS_URL = config.require("url").rstrip("/")
MORPHEUS_USERNAME = config.require("username")
MORPHEUS_PASSWORD = config.require_secret("password")
MORPHEUS_VALIDATE_CERTS = config.get_bool("validateCerts")
if MORPHEUS_VALIDATE_CERTS is None:
    MORPHEUS_VALIDATE_CERTS = True
MORPHEUS_SCOPE = config.get("scope") or "write"

REQUEST_TIMEOUT = 30


def _get_token(session: requests.Session, password: str) -> str:
    """Exchange username/password for an OAuth access token."""
    resp = session.post(
        f"{MORPHEUS_URL}/oauth/token",
        data={
            "client_id": "morph-api",
            "grant_type": "password",
            "scope": MORPHEUS_SCOPE,
            "username": MORPHEUS_USERNAME,
            "password": password,
        },
        timeout=REQUEST_TIMEOUT,
    )
    if resp.status_code != 200:
        # Deliberately does not include the request body (password) in the error.
        raise Exception(
            f"Token request to {MORPHEUS_URL}/oauth/token failed "
            f"(status {resp.status_code}): {resp.text} -- for a self-signed / lab "
            f"appliance certificate set morpheus:validateCerts false."
        )
    token = resp.json().get("access_token")
    if not token:
        raise Exception("Authentication succeeded but no access_token was returned.")
    return token


def _get_json(session: requests.Session, path: str) -> Dict[str, Any]:
    resp = session.get(f"{MORPHEUS_URL}{path}", timeout=REQUEST_TIMEOUT)
    if resp.status_code != 200:
        raise Exception(f"GET {MORPHEUS_URL}{path} failed (status {resp.status_code}): {resp.text}")
    return resp.json()


def list_clouds_and_instances(password: str) -> List[Dict[str, Any]]:
    """Return each cloud and the trimmed instance list provisioned in it."""
    if not MORPHEUS_VALIDATE_CERTS:
        # Avoid noisy warnings when talking to a self-signed / lab appliance.
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    session = requests.Session()
    session.verify = MORPHEUS_VALIDATE_CERTS

    token = _get_token(session, password)
    session.headers.update({"Authorization": f"BEARER {token}"})

    # /api/zones returns clouds under ".zones"; the /api/clouds alias (not on all
    # appliances) uses ".clouds". Support both keys.
    zones_body = _get_json(session, "/api/zones?max=1000")
    clouds = zones_body.get("zones") or zones_body.get("clouds") or []

    result: List[Dict[str, Any]] = []
    for cloud in clouds:
        instances_body = _get_json(session, f"/api/instances?max=1000&zoneId={cloud['id']}")
        instances = instances_body.get("instances") or []
        result.append(
            {
                "cloud_id": cloud.get("id"),
                "cloud_name": cloud.get("name"),
                "instances": [
                    {"id": i.get("id"), "name": i.get("name"), "status": i.get("status")}
                    for i in instances
                ],
            }
        )
    return result


# Run the API calls inside apply() so the secret password is never materialized
# into stack state. The result holds only non-sensitive listing data.
clouds_output = MORPHEUS_PASSWORD.apply(list_clouds_and_instances)

summary_output = clouds_output.apply(
    lambda clouds: [
        f"{c['cloud_name']} (id {c['cloud_id']}) - {len(c['instances'])} instance(s): "
        + str([i["name"] for i in c["instances"]])
        for c in clouds
    ]
)

# The listing is not sensitive; un-secret it so it is readable via
# `pulumi stack output clouds`.
pulumi.export("clouds", pulumi.Output.unsecret(clouds_output))
pulumi.export("summary", pulumi.Output.unsecret(summary_output))
