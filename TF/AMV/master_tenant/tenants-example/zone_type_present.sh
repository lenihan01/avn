#!/usr/bin/env bash
#
# Report whether a Morpheus cloud (zone) type code is installed on the appliance.
#
# Intended as a Terraform `external` data source program (data.external): it lets
# resource creation be gated on a cloud type actually existing -- e.g. the HPE
# bare-metal cloud, whose type ("hpe-baremetal-plugin.cloud") only appears in
# /api/zone-types once the bare-metal plugin is installed. Unlike the provider's
# hpe_morpheus_cloud_type data source (which hard-errors when the type is
# absent, failing the whole plan), this returns present=false so callers can
# skip the resource with count.
#
# Terraform passes the query as a JSON object on stdin; this script reads these
# keys from it (the external provider forbids passing secrets any other way):
#   url        Morpheus base URL
#   username   Master-tenant admin username
#   password   Master-tenant admin password
#   insecure   "true" to skip TLS verification, otherwise "false"
#   code       The zone-type code to look for
#
# It prints a JSON object to stdout: {"present": "true"|"false"}.
set -euo pipefail

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required command '$cmd' is not installed" >&2
    exit 1
  }
done

INPUT=$(cat)
URL=$(jq -r '.url' <<<"${INPUT}")
USERNAME=$(jq -r '.username' <<<"${INPUT}")
PASSWORD=$(jq -r '.password' <<<"${INPUT}")
INSECURE=$(jq -r '.insecure' <<<"${INPUT}")
CODE=$(jq -r '.code' <<<"${INPUT}")

if [ -z "${URL}" ] || [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ] || [ -z "${CODE}" ]; then
  echo "ERROR: url, username, password and code are all required" >&2
  exit 1
fi

CURL_OPTS=(--silent --show-error --location)
if [ "${INSECURE}" = "true" ]; then
  CURL_OPTS+=(--insecure)
fi

# 1) Authenticate as the master admin and obtain an OAuth token.
TOKEN=$(curl "${CURL_OPTS[@]}" \
  --data-urlencode "client_id=morph-api" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "scope=write" \
  --data-urlencode "username=${USERNAME}" \
  --data-urlencode "password=${PASSWORD}" \
  "${URL}/oauth/token" | jq -r '.access_token // empty')

if [ -z "${TOKEN}" ]; then
  echo "ERROR: could not obtain a Morpheus API token for '${USERNAME}'" >&2
  exit 1
fi

# 2) List zone types and check whether the requested code is present. max=-1
#    returns all rows so paging can't hide the match.
PRESENT=$(curl -G "${CURL_OPTS[@]}" \
  -H "Authorization: Bearer ${TOKEN}" \
  --data-urlencode "max=-1" \
  "${URL}/api/zone-types" \
  | jq -r --arg c "${CODE}" 'any(.zoneTypes[]?; .code == $c) | tostring')

# jq prints "true"/"false"; default to "false" if anything went wrong.
if [ "${PRESENT}" != "true" ]; then
  PRESENT="false"
fi

jq -n --arg present "${PRESENT}" '{present: $present}'
