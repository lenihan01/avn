#!/bin/bash
# (C) Copyright 2025-2026 Hewlett Packard Enterprise Development LP

set +eux

verbose="1"

operation="POST"
protocol="https://"
endpoint="/oauth/token"
args="?client_id=morph-automation&grant_type=password&scope=write"

. ../lib/functions.sh

# Check env vars are set
if [[ -z "${URL}" ]]; then
  echo "URL env var not set!"
  exit 1
elif [[ -z "${USER}" ]]; then
  echo "USER env var not set!"
  exit 1
elif [[ -z "${PASSWORD}" ]]; then
  echo "PASSWORD env var not set!"
  exit 1
fi

token=`curl --insecure --request POST \
     --url "${protocol}${URL}${endpoint}${args}" \
     --header "accept: application/json" \
     --header "content-type: application/x-www-form-urlencoded" \
     --data username=${USER} \
     --data "password=${PASSWORD}" | jq -r .access_token`

# Create a Cloud using the token we just generated
#
operation="POST"
protocol="https://"
endpoint="/api/zones"
args=""

# Print out what we are doing
echo "${operation} ${protocol}${URL}${endpoint}${args}"

curl --insecure --request $operation \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "content-type: application/json" \
  --header "authorization: Bearer ${token}" \
  -d '
{
  "zone": {
    "zoneType": {
      "id": 2,
    },
    "config": {
      "useHostCredentials": "on",
      "ebsEncryption": "on",
      "rpcMode": "guestexec",
      "applianceUrl": "",
      "datacenterName": "DCName",
      "inventoryLevel": "full",
      "consoleKeymap": "UK",
      "apiUrl": "https://vcenter9.cs8.local",
      "apiVersion": "7.0",
      "guidanceMode": "off",
      "datacenter": "DC9",
      "storageType": "thin",
      "certificateProvider": "internal",
      "cluster": "CL9",
      "resourcePoolId": "",
      "username": "administrator@vsphere.local",
      "password": "<redacted>"
    },
    "agentMode": "cloudInit",
    "visibility": "public",
    "enabled": true,
    "autoRecoverPowerState": false,
    "scalePriority": 1,
    "securityMode": "off",
    "name": "Aeven vSphere Cloud",
    "groupId": 3,
    "description": "Aeven vSphere Cloud",
    "code": "mycloud",
    "location": "AMV",
    "accountId": 1,
    "defaultDatastoreSyncActive": true,
    "defaultNetworkSyncActive": true,
    "defaultFolderSyncActive": true,
    "defaultSecurityGroupSyncActive": true,
    "defaultPoolSyncActive": true,
    "defaultPlanSyncActive": true
  }
}
'

