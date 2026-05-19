# (C) Copyright 2025 Hewlett Packard Enterprise Development LP
#!/bin/bash

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
endpoint="/api/catalog-item-types"
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
  "catalogItemType": {
    "visibility": "private",
    "enabled": true,
    "featured": false,
    "allowQuantity": false,
    "workflow": {
      "id": 27
    },
    "formType": "optionTypes",
    "description": "aeven",
    "type": "workflow",
    "context": "instance",
    "name": "aeven-catalog-item"
  }
}

'
