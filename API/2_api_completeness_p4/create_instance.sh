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
      "code": "hpe-baremetal-plugin.provision"
    },
    "layout": {
      "id": 277 
    },
    "plan": {
      "id": 244 
    },
    "name": "jlanurag2",
    "hostName": "jlanurag2"
  },
  "copies": 1,
  "layoutSize": 1,
  "config": {
    "createUser": true,
    "imageId": 189,
    "noAgent": false
  },
  "zoneId": 1,
  "volumes": [
    {
      "id": -1,
      "rootVolume": true,
      "name": "root",
      "size": 20
    }
  ],
  "networkInterfaces": [
    {
      "network": {
        "id": "network-4",
        "pool": {
          "id":1 
        }
      },
      "ipMode": "",
      "networkInterfaceTypeId": 18,
      "networkInterfaces": [
        {
          "network": {
            "id": "network-4",
            "pool": {
              "id": 1 
            }
          },
          "ipMode": "",
          "networkInterfaceTypeId": 19
        }
      ]
    },
    {
      "network": {
        "id": "network-4",
        "pool": {
          "id": 1 
        }
      },
      "ipMode": "",
      "networkInterfaceTypeId": 18 
    }
  ]
}
'
