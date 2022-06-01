terraform {
  cloud {
    organization = "hashi_strawb_demo"

    workspaces {
      tags = ["demo", "vault"]
    }
  }
}

provider "vault" {
  address = "https://127.0.0.1:8200/"
  token   = "root"
}

#
# Cert Auth
#

resource "vault_auth_backend" "cert" {
  type = "cert"
}

data "http" "ca" {
  url = "https://vault.lmhd.me/v1/pki/root/ca/pem"
}

resource "vault_cert_auth_backend_role" "example" {
  name                 = "example"
  certificate          = data.http.ca.body
  backend              = vault_auth_backend.cert.path
  allowed_common_names = ["localhost"]
  token_ttl            = 300
  token_max_ttl        = 600
  token_policies       = ["default", "policy-from-role"]
}




#
# Identities
#


resource "vault_identity_entity" "test" {
  name     = "localhost_cert"
  policies = ["policy-from-entity"]
}
resource "vault_identity_entity_alias" "test" {
  # Find certs with localhost in their Subject Common Name
  name           = "localhost"
  mount_accessor = vault_auth_backend.cert.accessor
  canonical_id   = vault_identity_entity.test.id
}

resource "vault_identity_group" "test" {
  name     = "test-group"
  type     = "internal"
  policies = ["policy-from-group"]
}


resource "vault_identity_group_member_entity_ids" "members" {
  exclusive = false
  member_entity_ids = [
    vault_identity_entity.test.id
  ]
  group_id = vault_identity_group.test.id
}
