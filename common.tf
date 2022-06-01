provider "vault" {
  address   = var.vault_address
  alias     = "create-namespace"
  namespace = "demos/"
}

resource "vault_namespace" "demo" {
  provider = vault.create-namespace
  path     = var.vault_namespace
}

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
  namespace = vault_namespace.demo.id
}

variable "vault_address" {
  type    = string
  default = "https://vault.lmhd.me"
}

variable "vault_namespace" {
  type = string
}
