#!/usr/bin/env bash
#
# Set the TOP-LEVEL inventory level on a Morpheus cloud (zone) via the API.
#
# This exists because the hpe_morpheus_cloud resource (provider v1.5.0) only
# writes "inventoryLevel" into the cloud's nested "config" map -- the request
# model (AddCloudsRequestZone) has no top-level inventoryLevel field. Morpheus,
# however, drives VM inventory off the TOP-LEVEL zone.inventoryLevel property,
# which therefore stays "off" no matter what import_existing_vms is set to. The
# symptom: existing hosts are inventoried but no VMs (serverCounts.vm == 0).
# A direct PUT of {"zone":{"inventoryLevel":"..."}} sets the real property.
#
# Required environment variables (all set by the local-exec provisioner):
#   MORPH_URL         Morpheus base URL (e.g. https://morpheus.example.local)
#   MORPH_USER        Master-tenant admin username
#   MORPH_PASS        Master-tenant admin password
#   MORPH_INSECURE    "true" to skip TLS verification, otherwise "false"
#   CLOUD_ID          Zone (cloud) id to update
#   INVENTORY_LEVEL   Desired top-level inventory level: off, basic, or full
set -euo pipefail

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command '$cmd' is not installed" >&2
    exit 1
  }
done

: "${MORPH_URL:?}" "${MORPH_USER:?}" "${MORPH_PASS:?}"
: "${CLOUD_ID:?}" "${INVENTORY_LEVEL:?}"

case "${INVENTORY_LEVEL}" in
  off | basic | full) ;;
  *)
    echo "ERROR: INVENTORY_LEVEL must be one of off, basic, full (got '${INVENTORY_LEVEL}')" >&2
    exit 1
    ;;
esac

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

# 2) Idempotency: skip the PUT if the top-level level is already as desired.
CURRENT=$(curl "${CURL_OPTS[@]}" "${AUTH[@]}" \
  "${MORPH_URL}/api/zones/${CLOUD_ID}" \
  | jq -r '.zone.inventoryLevel // empty')

if [ "${CURRENT}" = "${INVENTORY_LEVEL}" ]; then
  echo "cloud ${CLOUD_ID} already has inventoryLevel='${INVENTORY_LEVEL}'; nothing to do"
  exit 0
fi

# 3) PUT the top-level inventoryLevel.
BODY=$(jq -n --arg lvl "${INVENTORY_LEVEL}" '{zone: {inventoryLevel: $lvl}}')

RESP_FILE=$(mktemp)
trap 'rm -f "${RESP_FILE}" "${AUTH_FILE}"' EXIT

CODE=$(curl "${CURL_OPTS[@]}" -o "${RESP_FILE}" -w '%{http_code}' \
  -X PUT "${MORPH_URL}/api/zones/${CLOUD_ID}" \
  "${AUTH[@]}" -H "Content-Type: application/json" \
  --data "${BODY}")

NEW_LEVEL=$(jq -r '.zone.inventoryLevel // empty' <"${RESP_FILE}" 2>/dev/null || true)

if [ "${CODE}" = "200" ] && [ "${NEW_LEVEL}" = "${INVENTORY_LEVEL}" ]; then
  echo "set cloud ${CLOUD_ID} inventoryLevel='${NEW_LEVEL}'"
  exit 0
fi

echo "ERROR: failed to set inventoryLevel on cloud ${CLOUD_ID} (HTTP ${CODE}):" >&2
cat "${RESP_FILE}" >&2
exit 1
