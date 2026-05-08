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
endpoint="/api/accounts"
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
  "zone": {
    "zoneType": {
      "id": 3
    },
    "config": {
      "useHostCredentials": "on",
      "ebsEncryption": "on",
      "rpcMode": "guestexec",
      "applianceUrl": "https://vsphere.hpelabs.local",
      "datacenterName": "DCName",
      "inventoryLevel": "full",
      "consoleKeymap": "UK",
      "apiUrl": "https://vcenter.morpheus.local/sdk",
      "apiVersion": "7.0",
      "datacenter": "DCName",
      "storageType": "thin",
      "certificateProvider": "internal",
      "cluster": "all"
    },
    "agentMode": "cloudInit",
    "visibility": "public",
    "enabled": true,
    "autoRecoverPowerState": false,
    "scalePriority": 1,
    "securityMode": "off",
    "name": "My Cloud",
    "groupId": 3,
    "description": "My Cloud",
    "code": "mycloud",
    "location": "ALF",
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
