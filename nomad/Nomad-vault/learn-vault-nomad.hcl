job "nomad-vault" {
  datacenters = ["homelab"]
  type = "batch"  # One-time job
  group "web" {
    task "server" {
      vault {
        policies = ["myapp"]
        change_mode = "restart"
      }
      
      template {
        data = <<EOH
{{ with secret "secret/data/myapp/database" }}
DB_USER="{{ .Data.data.username }}"
DB_PASS="{{ .Data.data.password }}"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
    }
  }
}
