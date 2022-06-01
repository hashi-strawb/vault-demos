#!/bin/bash
set -e

export VAULT_ADDR=https://vault.lmhd.me

echo
echo ========================================
echo auth with LMHD vault
echo ========================================

vault token lookup 2>/dev/null || \
	vault login -method=oidc -path=okta_oidc


echo
echo ========================================
echo generate cert for local vault
echo ========================================

vault write -format=json pki/inter/issue/localhost common_name=localhost ip_sans=0.0.0.0,127.0.0.1 | jq .data | tee vault-cert.json
cat vault-cert.json | jq -r .certificate | tee vault-cert.pem
cat vault-cert.json | jq -r .ca_chain[] | tee -a vault-cert.pem
cat vault-cert.json | jq -r .private_key | tee vault-key.pem


unset VAULT_ADDR

echo
echo ========================================
echo run local vault
echo ========================================

vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id=root -dev-no-store-token -config=dev-tls-config.hcl
