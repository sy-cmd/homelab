# This job Exposes the secret to nomad
job "nomad-vault-secrets" {
  datacenters = ["homelab"]
  type = "batch"  # One-time job
  
  
  group "secret-processing" {
    task "get-db-password" {
      driver = "raw_exec"  # Simple executor
      config {
        command = "sh"
        args    = ["-c", "echo 'DB_PASSWORD=${db_password}' > /tmp/secret-output.env"]
      }

      vault {
        policies = ["nomad-cluster"]  
      }

      template {
        data = <<EOH
{{ with secret "nomad-secrets/webapp" }}
db_password = "{{ .Data.data.db_password }}"
{{ end }}
EOH
        destination = "local/secrets.env"
        env         = true  # Expose as environment variable
      }
    }
  }
}
