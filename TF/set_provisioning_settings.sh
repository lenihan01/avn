#!/usr/bin/env bash
#
# Set the appliance-wide cloud-init provisioning credentials via the Morpheus
# API (PUT /api/provisioning-settings).
#
# This exists because the hpe_morpheus_setting_provisioning resource (provider
# v1.5.0) is unusable against this appliance: after PUTting the settings it
# asserts the response body contains a "provisioningSettings" object and errors
# with "Not found in response: ProvisioningSettings" when it doesn't. Morpheus'
# update endpoint only returns {"success":true} (no echoed object), so the
# update actually succeeds but the provider fails the apply. PUTting directly
# sidesteps the broken response check.
#
# Required environment variables (all set by the local-exec provisioner):
#   MORPH_URL           Morpheus base URL (e.g. https://morpheus.example.local)
#   MORPH_USER          Master-tenant admin username
#   MORPH_PASS          Master-tenant admin password
#   MORPH_INSECURE      "true" to skip TLS verification, otherwise "false"
#
# Optional environment variables (each PUT only when non-empty):
#   CLOUDINIT_USERNAME  Default cloud-init username for provisioned instances
#   CLOUDINIT_PASSWORD  Default cloud-init password for provisioned instances
set -euo pipefail

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command '$cmd' is not installed" >&2
    exit 1
  }
done

: "${MORPH_URL:?}" "${MORPH_USER:?}" "${MORPH_PASS:?}"

CLOUDINIT_USERNAME="${CLOUDINIT_USERNAME:-}"
CLOUDINIT_PASSWORD="${CLOUDINIT_PASSWORD:-}"

if [ -z "${CLOUDINIT_USERNAME}" ] && [ -z "${CLOUDINIT_PASSWORD}" ]; then
  echo "nothing to do: neither CLOUDINIT_USERNAME nor CLOUDINIT_PASSWORD is set"
  exit 0
fi

CURL_OPTS=(--silent --show-error --location)
if [ "${MORPH_INSECURE:-false}" = "true" ]; then
  CURL_OPTS+=(--insecure)
fi

# 1) Authenticate as the master admin and obtain an OAuth token. The password is
#    fed to curl on stdin (--data-urlencode password@-) so it never appears in
#    the process command line / argv, where any local user could read it via ps.
TOKEN=$(printf '%s' "${MORPH_PASS}" | curl "${CURL_OPTS[@]}" \
  --data-urlencode "client_id=morph-api" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "scope=write" \
  --data-urlencode "username=${MORPH_USER}" \
  --data-urlencode "password@-" \
  "${MORPH_URL}/oauth/token" | jq -r '.access_token // empty')

if [ -z "${TOKEN}" ]; then
  echo "ERROR: could not obtain a Morpheus API token for '${MORPH_USER}'" >&2
  exit 1
fi

# Keep the bearer token out of argv by passing it to curl from a 0600 temp file
# (curl -H @file) instead of on the command line.
AUTH_FILE=$(mktemp)
trap 'rm -f "${AUTH_FILE}"' EXIT
printf 'Authorization: BEARER %s\n' "${TOKEN}" >"${AUTH_FILE}"
AUTH=(-H "@${AUTH_FILE}")

# 2) Build the request body, including only the attributes that are set. Every
#    other provisioning setting is left at its current appliance value.
BODY=$(jq -n \
  --arg u "${CLOUDINIT_USERNAME}" \
  --arg p "${CLOUDINIT_PASSWORD}" \
  '{provisioningSettings: (
      {}
      + (if $u == "" then {} else {cloudInitUsername: $u} end)
      + (if $p == "" then {} else {cloudInitPassword: $p} end)
   )}')

# 3) PUT the settings. Morpheus responds with {"success":true} and no echoed
#    object, so success is determined from the .success flag.
RESP_FILE=$(mktemp)
trap 'rm -f "${RESP_FILE}" "${AUTH_FILE}"' EXIT

# The request body carries the cloud-init password, so pipe it to curl on stdin
# (--data @-) rather than passing it as a command-line argument.
CODE=$(printf '%s' "${BODY}" | curl "${CURL_OPTS[@]}" -o "${RESP_FILE}" -w '%{http_code}' \
  -X PUT "${MORPH_URL}/api/provisioning-settings" \
  "${AUTH[@]}" -H "Content-Type: application/json" \
  --data @-)

if [ "${CODE}" = "200" ] && [ "$(jq -r '.success // false' <"${RESP_FILE}")" = "true" ]; then
  echo "updated provisioning settings (cloud-init credentials)"
  exit 0
fi

echo "ERROR: failed to update provisioning settings (HTTP ${CODE}):" >&2
cat "${RESP_FILE}" >&2
exit 1
