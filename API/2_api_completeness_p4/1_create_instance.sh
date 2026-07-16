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
endpoint="/api/instances"
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
      "id": 1
    },
    "instanceType": {
      "code": "ubuntu"
    },
    "layout": {
      "id": 212
    },
    "plan": {
      "id": 30
    },
    "name": "jlanurag2",
    "hostName": "jlanurag2"
  },
  "copies": 1,
  "layoutSize": 1,
  "config": {
    "createUser": true,
    "resourcePoolId": "pool-53",
    "noAgent": false
  },
  "zoneId": 7,
  "volumes": [
    {
      "id": -1,
      "rootVolume": true,
      "datastoreId": "62",
      "name": "root",
      "size": 20
    }
  ],
  "networkInterfaces": [
    {
      "network": {
        "id": 48,
        "pool": {
          "id":1
        }
      },
      "ipMode": "",
      "networkInterfaceTypeId": 18,
    }
  ]
}
'
