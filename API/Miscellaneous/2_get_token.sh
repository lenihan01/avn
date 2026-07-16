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
curl --insecure --request POST \
     --url "${protocol}${URL}${endpoint}${args}" \
     --header "accept: application/json" \
     --header "content-type: application/x-www-form-urlencoded" \
     --data username=${USER} \
     --data "password=${PASSWORD}"
