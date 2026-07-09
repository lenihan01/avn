#!/usr/bin/env bash
#
# Idempotently create a tenant "bootstrap admin" user via the Morpheus API.
#
# This exists because the hpe_morpheus_user resource cannot create the FIRST
# user of a sub-tenant when the role is a multitenant master role: Morpheus
# swaps in the tenant-local copy of the role id, and Terraform's post-apply
# consistency check then fails ("planned ... does not correlate with any element
# in actual"). Creating the admin straight through the API sidesteps Terraform's
# check entirely. Once the admin exists, the sub-tenant providers can
# authenticate as it and resolve tenant-local role ids for the normal users.
#
# Required environment variables (all set by the local-exec provisioner):
#   MORPH_URL       Morpheus base URL (e.g. https://morpheus.example.local)
#   MORPH_USER      Master-tenant admin username
#   MORPH_PASS      Master-tenant admin password
#   MORPH_INSECURE  "true" to skip TLS verification, otherwise "false"
#   TENANT_ID       Sub-tenant (account) id to create the user in
#   ADMIN_USER      Bootstrap admin username
#   ADMIN_EMAIL     Bootstrap admin email
#   ADMIN_PASS      Bootstrap admin password
#   ROLE_ID         Master admin role id to assign (Morpheus maps it to the
#                   tenant-local copy server-side)
#
# Optional environment variables (each included only when non-empty):
#   LINUX_USER      Linux username set on the user (guest OS default)
#   LINUX_PASS      Linux password set on the user
#   WINDOWS_USER    Windows username set on the user (guest OS default)
#   WINDOWS_PASS    Windows password set on the user
set -euo pipefail

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command '$cmd' is not installed" >&2
    exit 1
  }
done

: "${MORPH_URL:?}" "${MORPH_USER:?}" "${MORPH_PASS:?}" "${TENANT_ID:?}"
: "${ADMIN_USER:?}" "${ADMIN_EMAIL:?}" "${ADMIN_PASS:?}" "${ROLE_ID:?}"

CURL_OPTS=(--silent --show-error --location)
if [ "${MORPH_INSECURE:-false}" = "true" ]; then
  CURL_OPTS+=(--insecure)
fi

# 1) Authenticate as the master admin and obtain an OAuth token.
TOKEN=$(curl "${CURL_OPTS[@]}" \
  --data-urlencode "client_id=morph-api" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "scope=write" \
  --data-urlencode "username=${MORPH_USER}" \
  --data-urlencode "password=${MORPH_PASS}" \
  "${MORPH_URL}/oauth/token" | jq -r '.access_token // empty')

if [ -z "${TOKEN}" ]; then
  echo "ERROR: could not obtain a Morpheus API token for '${MORPH_USER}'" >&2
  exit 1
fi

AUTH=(-H "Authorization: Bearer ${TOKEN}")

# 2) Idempotency: if the admin already exists in this tenant, do nothing.
#    (Handles re-runs and admins left behind by earlier failed applies.)
if curl -G "${CURL_OPTS[@]}" "${AUTH[@]}" \
      --data-urlencode "accountId=${TENANT_ID}" \
      --data-urlencode "phrase=${ADMIN_USER}" \
      "${MORPH_URL}/api/users" \
    | jq -e --arg u "${ADMIN_USER}" '.users[]? | select(.username == $u)' >/dev/null 2>&1; then
  echo "admin '${ADMIN_USER}' already exists in tenant ${TENANT_ID}; nothing to do"
  exit 0
fi

# 3) Create the admin user in the sub-tenant.
#
# Optionally set Linux/Windows credentials (used as the default guest OS
# username/password for instances provisioned by this user). Each field is
# included in the request only when its env var is non-empty, so callers that
# don't set them create the user unchanged.
BODY=$(jq -n \
  --arg u "${ADMIN_USER}" \
  --arg e "${ADMIN_EMAIL}" \
  --arg p "${ADMIN_PASS}" \
  --argjson r "${ROLE_ID}" \
  --arg lu "${LINUX_USER:-}" \
  --arg lp "${LINUX_PASS:-}" \
  --arg wu "${WINDOWS_USER:-}" \
  --arg wp "${WINDOWS_PASS:-}" \
  '{user: (
      {username: $u, email: $e, password: $p, roles: [{id: $r}]}
      + (if $lu == "" then {} else {linuxUsername: $lu} end)
      + (if $lp == "" then {} else {linuxPassword: $lp} end)
      + (if $wu == "" then {} else {windowsUsername: $wu} end)
      + (if $wp == "" then {} else {windowsPassword: $wp} end)
   )}')

RESP_FILE=$(mktemp)
trap 'rm -f "${RESP_FILE}"' EXIT

CODE=$(curl "${CURL_OPTS[@]}" -o "${RESP_FILE}" -w '%{http_code}' \
  -X POST "${MORPH_URL}/api/users?accountId=${TENANT_ID}" \
  "${AUTH[@]}" -H "Content-Type: application/json" \
  --data "${BODY}")

USER_ID=$(jq -r '.user.id // empty' <"${RESP_FILE}" 2>/dev/null || true)

if [ "${CODE}" = "200" ] && [ -n "${USER_ID}" ]; then
  echo "created admin '${ADMIN_USER}' (id ${USER_ID}) in tenant ${TENANT_ID}"
  exit 0
fi

# Tolerate a race/duplicate where the user already exists.
if grep -qiE 'already|exists|taken|duplicate' "${RESP_FILE}"; then
  echo "admin '${ADMIN_USER}' already exists in tenant ${TENANT_ID}; nothing to do"
  exit 0
fi

echo "ERROR: failed to create admin '${ADMIN_USER}' in tenant ${TENANT_ID} (HTTP ${CODE}):" >&2
cat "${RESP_FILE}" >&2
exit 1
