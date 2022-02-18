terraform {
  cloud {
    organization = "hashi_strawb_demo"

    workspaces {
      tags = ["demo", "vault"]
    }
  }
}

provider "vault" {
  address   = var.vault_address
  namespace = var.vault_namespace
}

resource "vault_mount" "kv" {
  path        = "self-deleting-secrets"
  type        = "kv-v2"
  description = "This is just a standard KVv2 Secret Engine"
}

resource "time_sleep" "wait" {
  depends_on = [vault_mount.kv]

  create_duration = "5s"
}

resource "vault_generic_endpoint" "kv-config" {
  # Wait for Vault KV to be upgraded to v2
  depends_on = [time_sleep.wait]

  path                 = "${vault_mount.kv.path}/config"
  ignore_absent_fields = true
  disable_delete       = true

  data_json = <<EOT
{
	"delete_version_after": "1m0s"
}
EOT
}
