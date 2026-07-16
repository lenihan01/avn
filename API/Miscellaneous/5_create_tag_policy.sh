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
fi

operation="POST"
protocol="https://"
endpoint="/api/policies"
args=""

# Print out what we are doing
echo "${operation} ${protocol}${URL}${endpoint}${args}"

curl --insecure --request $operation \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "content-type: application/json" \
  --header "authorization: Bearer ${TOKEN}" \
  -d '
{
  "policy": {
    "config": {
      "strict": "true",
      "key": "mykey",
      "valueListId": 92,
      "value": ""
    },
    "policyType": {
      "code": "tags"
    },
    "name": "HCTA Sample Tag Policy",
    "description": "HCTA Sample Tag Policy",
    "enabled": "off",
    },
    "accounts": null
  }
}
'
 

