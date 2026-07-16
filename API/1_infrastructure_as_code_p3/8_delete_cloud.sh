#!/bin/bash
# (C) Copyright 2025-2026 Hewlett Packard Enterprise Development LP

set +eux

. ../lib/functions.sh

# Check env vars are set
if [[ -z "${URL}" ]]; then
  echo "URL env var not set!"
  exit 1
elif [[ -z "${TOKEN}" ]]; then
  echo "TOKEN env var not set!"
  exit 1
elif [[ -z "${ID}" ]]; then
  echo "ID env var not set!"
  exit 1
fi

operation="DELETE"
protocol="https://"
endpoint="/api/zones/${ID}"
args="?preserveVolumes=off&keepBackups=off&releaseFloatingIps=on&releaseEIPs=on&force=true"

# Print out what we are doing
echo "${operation} ${protocol}${URL}${endpoint}${args}"

curl --insecure --request $operation \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "authorization: Bearer ${TOKEN}"
