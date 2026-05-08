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
elif [[ -z "${ID}" ]]; then
  echo "ID env var not set!"
  exit 1
fi

operation="PUT"
protocol="https://"
endpoint="/api/instances/${ID}"
args=""

# Print out what we are doing
echo "${operation} ${protocol}${URL}${endpoint}${args}"

curl --insecure --request $operation \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "content-type: application/json" \
  --header "authorization: Bearer ${TOKEN}" \
  --data '
{
  "instance": {
    "site": {
      "id": 5
    },
    "metadata": [
      {
        "name": "tag1name",
        "value": "tag1value"
      },
      {
        "name": "tag2name",
        "value": "tag2value"
      }
    ],
    "name": "jltestinstance1",
    "displayName": "jltestinstance1",
    "instanceContext": "Dev",
    "labels": [
      "foo"
    ]
  }
}
'
