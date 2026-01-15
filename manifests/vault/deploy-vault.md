# Vault Integration and Configuration

Complete guide for setting up HashiCorp Vault in k3s homelab with Kubernetes authentication and secrets management.

## 🚀 Vault Deployment

### Kubernetes Manifests
+ we use a chart that configures everything for us 
> $ helm repo add hashicorp https://helm.releases.hashicorp.com
 "hashicorp" has been added to your repositories

> $ helm install vault hashicorp/vault



## 🔐 Policies and Roles

### Vault Policies
```hcl
# policies/gitea-runner.hcl
path "secret/data/gitea/runner/*" {
  capabilities = ["read", "list"]
}

path "secret/data/gitea/tokens/*" {
  capabilities = ["read", "list"]
}

path "secret/data/database/*" {
  capabilities = ["read"]
}

path "auth/token/renew" {
  capabilities = ["update"]
}
```

```hcl
# policies/admin.hcl
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

### Kubernetes Roles
```bash
# Create roles for different services
#!/bin/bash
# scripts/vault-roles.sh

VAULT_POD=$(kubectl get pods -l app=vault -o jsonpath='{.items[0].metadata.name}')
ROOT_TOKEN=$(cat ~/.vault/homelab/root_token.txt)

kubectl exec $VAULT_POD -- vault login $ROOT_TOKEN

# Gitea Runner role
kubectl exec $VAULT_POD -- vault write auth/kubernetes/role/gitea-runner \
  bound_service_account_names=gitea-runner \
  bound_service_account_namespaces=default \
  policies=gitea-runner \
  ttl=24h \
  max_ttl=72h

# GitLab Runner role
kubectl exec $VAULT_POD -- vault write auth/kubernetes/role/gitlab-runner \
  bound_service_account_names=gitlab-runner \
  bound_service_account_namespaces=default \
  policies=gitea-runner \
  ttl=24h \
  max_ttl=72h

# Admin role
kubectl exec $VAULT_POD -- vault write auth/kubernetes/role/admin \
  bound_service_account_names=vault-admin \
  bound_service_account_namespaces=default \
  policies=admin \
  ttl=8h \
  max_ttl=24h

echo "Vault roles created successfully!"
```

## 🗄️ Secrets Management

### Store Secrets
```bash
#!/bin/bash
# scripts/store-secrets.sh

VAULT_POD=$(kubectl get pods -l app=vault -o jsonpath='{.items[0].metadata.name}')
ROOT_TOKEN=$(cat ~/.vault/homelab/root_token.txt)

kubectl exec $VAULT_POD -- vault login $ROOT_TOKEN

# Gitea tokens
kubectl exec $VAULT_POD -- vault kv put secret/gitea/tokens/runner \
  token="gitea_runner_token_here" \
  username="gitea-runner" \
  expires="2024-12-31"

# Database credentials
kubectl exec $VAULT_POD -- vault kv put secret/database/postgres \
  username="postgres" \
  password="secure_password_here" \
  host="postgres-service" \
  port="5432" \
  database="homelab"

# API keys
kubectl exec $VAULT_POD -- vault kv put secret/api/external \
  api_key="external_api_key_here" \
  endpoint="https://api.example.com" \
  timeout="30s"

# SSH keys
kubectl exec $VAULT_POD -- vault kv put secret/ssh/deploy \
  private_key="$(cat ~/.ssh/id_rsa)" \
  public_key="$(cat ~/.ssh/id_rsa.pub)" \
  passphrase=""

echo "Secrets stored successfully!"
```

### Dynamic Secrets
```bash
# Configure database dynamic secrets
kubectl exec $VAULT_POD -- vault write database/config/postgres \
  plugin_name=postgresql-database-plugin \
  connection_url="postgresql://{{username}}:{{password}}@postgres-service:5432/homelab" \
  allowed_roles="readonly,readwrite" \
  username="vault" \
  password="vault_password"

# Create database roles
kubectl exec $VAULT_POD -- vault write database/roles/readonly \
  db_name=postgres \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' INHERIT; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

kubectl exec $VAULT_POD -- vault write database/roles/readwrite \
  db_name=postgres \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' INHERIT; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"
```

## 🔄 Integration Examples

### GitLab Runner Integration
```yaml
# manifests/gitlab-runner/vault-integration.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-runner
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: gitlab-runner-token-reviewer
  namespace: default
rules:
- apiGroups: ["authentication.k8s.io"]
  resources: ["tokenreviews"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-token-reviewer-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: gitlab-runner
  namespace: default
roleRef:
  kind: Role
  name: gitlab-runner-token-reviewer
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab-runner
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/role: "gitlab-runner"
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-gitea-token: "secret/data/gitea/tokens/runner"
        vault.hashicorp.com/agent-inject-template-gitea-token: |
          {{- with secret "secret/data/gitea/tokens/runner" -}}
          export GITEA_TOKEN="{{ .Data.data.token }}"
          {{- end }}
        vault.hashicorp.com/agent-inject-secret-db-creds: "secret/data/database/postgres"
        vault.hashicorp.com/agent-inject-template-db-creds: |
          {{- with secret "secret/data/database/postgres" -}}
          export DB_USERNAME="{{ .Data.data.username }}"
          export DB_PASSWORD="{{ .Data.data.password }}"
          export DB_HOST="{{ .Data.data.host }}"
          export DB_PORT="{{ .Data.data.port }}"
          export DB_NAME="{{ .Data.data.database }}"
          {{- end }}
    spec:
      serviceAccountName: gitlab-runner
      containers:
      - name: gitlab-runner
        image: gitlab/gitlab-runner:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            # Source Vault secrets
            source /vault/secrets/gitea-token
            source /vault/secrets/db-creds
            
            # Register and start runner
            gitlab-runner register \
              --non-interactive \
              --url "https://gitlab.example.com" \
              --registration-token "$REGISTRATION_TOKEN" \
              --name "kubernetes-vault-runner" \
              --executor "kubernetes" \
              --kubernetes-namespace "default"
            
            gitlab-runner start
```

### Gitea Integration
```yaml
# manifests/gitea/vault-integration.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitea
  namespace: default
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitea
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/role: "gitea-runner"
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-secret-db-config: "secret/data/database/postgres"
        vault.hashicorp.com/agent-inject-template-db-config: |
          {{- with secret "secret/data/database/postgres" -}}
          DB_TYPE=postgres
          HOST={{ .Data.data.host }}
          PORT={{ .Data.data.port }}
          NAME={{ .Data.data.database }}
          USER={{ .Data.data.username }}
          PASSWD={{ .Data.data.password }}
          {{- end }}
    spec:
      serviceAccountName: gitea
      containers:
      - name: gitea
        image: gitea/gitea:1.21
        command: ["/bin/sh", "-c"]
        args:
          - |
            # Source Vault database config
            source /vault/secrets/db-config
            
            # Start Gitea with database config
            /usr/local/bin/gitea web -port 3000
```

## 📊 Monitoring and Health

### Health Check Script
```bash
#!/bin/bash
# scripts/vault-health-check.sh

VAULT_POD=$(kubectl get pods -l app=vault -o jsonpath='{.items[0].metadata.name}')
VAULT_ADDR="http://vault-service:8200"

echo "Checking Vault health..."

# Check Vault status
STATUS=$(kubectl exec $VAULT_POD -- vault status -format=json)
INITIALIZED=$(echo $STATUS | jq -r '.initialized')
SEALED=$(echo $STATUS | jq -r '.sealed')

if [ "$INITIALIZED" = "true" ]; then
  echo "✓ Vault is initialized"
else
  echo "✗ Vault is not initialized"
  exit 1
fi

if [ "$SEALED" = "false" ]; then
  echo "✓ Vault is unsealed"
else
  echo "✗ Vault is sealed"
  exit 1
fi

# Check auth methods
AUTH_METHODS=$(kubectl exec $VAULT_POD -- vault auth list | grep -c "Type")
echo "✓ Auth methods enabled: $AUTH_METHODS"

# Check secrets engines
SECRETS_ENGINES=$(kubectl exec $VAULT_POD -- vault secrets list | grep -c "Type")
echo "✓ Secrets engines enabled: $SECRETS_ENGINES"

# Test token creation
TEST_TOKEN=$(kubectl exec $VAULT_POD -- vault token create -policy=default -format=json | jq -r '.auth.client_token')
if [ -n "$TEST_TOKEN" ]; then
  echo "✓ Token creation working"
  kubectl exec $VAULT_POD -- vault token revoke $TEST_TOKEN
else
  echo "✗ Token creation failed"
  exit 1
fi

echo "Vault health check completed successfully!"
```

## 🔒 Security Best Practices

### Token Management
```bash
# Create short-lived tokens
kubectl exec $it vault-0 -- vault token create -policy=gitea-runner -ttl=1h

# Set up token renewal
kubectl exec -it vault-0 -- vault token renew -increment=1h $TOKEN

# Revoke tokens when no longer needed
kubectl exec -it vault-0 -- vault token revoke $TOKEN
```

### Audit Logging
```bash
# Enable audit device
kubectl exec -it vault-0 -- vault audit enable file file_path=/vault/vault-audit.log

# Check audit logs
kubectl exec -it vault-0 -- cat /vault/vault-audit.log
```

### Network Policies
```yaml
# manifests/vault/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vault-network-policy
spec:
  podSelector:
    matchLabels:
      app: vault
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: gitea
    - podSelector:
        matchLabels:
          app: gitlab-runner
    ports:
    - protocol: TCP
      port: 8200
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

## 🛠️ Troubleshooting

### Common Issues

1. **Vault Sealed**
   ```bash
   # Check status
   kubectl exec -it vault-0 -- vault status
   
   # Unseal with keys
   for key in $(cat ~/.vault/homelab/unseal_keys.txt); do
     kubectl exec -it vault-0 -- vault operator unseal $key
   done
   ```

2. **Kubernetes Auth Failed**
   ```bash
   # Check auth config
   kubectl exec -it vault-0 -- vault read auth/kubernetes/config
   
   # Test auth
   kubectl exec -it vault-0 -- vault write auth/kubernetes/login \
     role=gitea-runner \
     jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   ```

3. **Secret Not Found**
   ```bash
   # List secrets
   kubectl exec -it vault-0 -- vault kv list secret/
   
   # Check specific secret
   kubectl exec -it vault-0 -- vault kv get secret/gitea/tokens/runner
   ```

### Log Analysis
```bash
# Check audit logs
kubectl exec -it vault-0 -- tail -f /vault/vault-audit.log

# Check for errors
kubectl exec -it vault-0 -- grep -i error /vault/vault-audit.log
```

This comprehensive Vault setup provides secure secrets management for your homelab with proper authentication, policies, and integration with other services.