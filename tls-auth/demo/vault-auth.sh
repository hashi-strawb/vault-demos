#!/bin/bash
set -e

export VAULT_ADDR=https://127.0.0.1:8200

cat vault-cert.json | jq -r .certificate > cert.pem
cat vault-cert.json | jq -r .issuing_ca >> cert.pem
cat vault-cert.json | jq -r .private_key > key.pem

curl -s \
    --request POST \
    --cert cert.pem \
    --key key.pem \
    ${VAULT_ADDR}/v1/auth/cert/login > client-token.json


cat client-token.json | jq .
