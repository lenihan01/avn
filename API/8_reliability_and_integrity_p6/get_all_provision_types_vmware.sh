# (C) Copyright 2025 Hewlett Packard Enterprise Development LP
#!/bin/bash

set +eux

verbose="1"

. ../lib/functions.sh

# Check env vars are set
if [[ -z "${URL}" ]]; then
  echo "URL env var not set!"
  exit 1
elif [[ -z "${TOKEN}" ]]; then
  echo "TOKEN env var not set!"
  exit 1
fi

operation="GET"
protocol="https://"
endpoint="/api/provision-types"
args="?max=10000&offset=0&sort=name&direction=asc&name=VMware"

# Print out what we are doing
echo "${operation} ${protocol}${URL}${endpoint}${args}"

# If verbose is enabled, run the call but print the output.
if [[ ! -z "$verbose" ]]; then
curl --insecure --request $operation \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "authorization: Bearer ${TOKEN}" | jq .
fi

# Check response code
response=$(curl --insecure --request $operation \
  -so /dev/null -w "%{http_code}" \
  --url "${protocol}${URL}${endpoint}${args}" \
  --header "accept: application/json" \
  --header "authorization: Bearer ${TOKEN}")

check_response_code $response
