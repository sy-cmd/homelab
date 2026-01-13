path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "auth/token/create/nomad-cluster" {
  capabilities = ["update"]
}
