#!/bin/bash
set -e

export VAULT_ADDR=http://127.0.0.1:8200

echo
echo ========================================
echo auth with vault
echo ========================================

vault token lookup 2>/dev/null || \
	vault login -method=oidc -path=okta_oidc


echo
echo ========================================
echo generate cert
echo ========================================

vault write -format=json pki/issue/example.com common_name=test.example.com | jq .data | tee cert.json
cat cert.json | jq -r .certificate | tee cert.pem
cat cert.json | jq -r .private_key | tee key.pem
