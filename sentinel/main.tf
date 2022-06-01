resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv-v2"
  description = "This is just a standard KVv2 Secret Engine"
}

resource "vault_egp_policy" "mfa-and-cidr" {
  name              = "mfa-and-cidr"
  paths             = ["kv/data/*"]
  enforcement_level = "hard-mandatory"

  policy = <<EOT
import "sockaddr"
import "mfa"
import "strings"

# We expect logins to come only from our private IP range
cidrcheck = rule {
    sockaddr.is_contained("0.0.0.0/0", request.connection.remote_addr)
}

# Require Ping MFA validation to succeed
mfa_valid = rule {
    mfa.methods.duo.valid
}

# Requests must come from a specified IP range, and Duo MFA must pass
main = rule {
    cidrcheck and mfa_valid
}
EOT
}

resource "vault_egp_policy" "work-life-balance" {
  name              = "work-life-balance"
  paths             = ["*"]
  enforcement_level = "soft-mandatory"

  policy = <<EOT
import "time"

# We expect requests to only happen during work days (0 for Sunday, 6 for Saturday)
workdays = rule {
    time.now.weekday > 0 and time.now.weekday < 6 
}

# We expect requests to only happen during work hours
workhours = rule {
    time.now.hour > 7 and time.now.hour < 18 
}

main = rule {
    workdays and workhours
}
EOT
}
