how to set-up nomad vault integration 
+ we enable a secrete path at nomad
+  1.2 Configure the Nomad access
---  we include the nomad address and and the token if acl is allowed 
exmple 

   vault write nomad/config/access \
  address="http://192.168.50.80:4646" \
  token=""
  (since acl is disabled)
  vault write nomad/config/access \
  address="http://192.168.50.80:4646" \
  token="disabled-acls-placeholder-token"

we create a policy
with paths that we want to access
--name of the policy (nomad-server)

--Create a Vault token role for Nomad
 -- we create a vault token role for nomad ( this role authenticates the policy that we created to vault )

  vault write auth/token/roles/nomad-cluster \
  allowed_policies="nomad-server,default,nomad-cluster" \
  orphan=true \
  period="72h" \
  renewable=true

--Create a Vault policy for your application
 we create a new policy for our app name of the policy (  myapp )

 we create a role for the policy that authenticates the policy 

 vault write auth/token/roles/myapp-role \
  allowed_policies="myapp" \
  period="24h" \
  renewable=true

  
vault {
  enabled = true
  address = "http://192.168.50.35:8200"
  task_token_ttl = "1h"
  create_from_role = "nomad-cluster"
  token = ""
}