# Host Docker Registry on Kuberneties
we create two folders 
+ AUTH - here we store our credentials with htpassword 
+ CERT - this contains thhe certification  

### we create tls secrets 
+ `kubectl create secret tls certs-secret --cert=$Path -- key=$PATH` 

### we create secret for my htpassword 
+ `kubectl create generic auth-secret --from-file=$PATH`

# PV 
+ longhorn is being used to persistentVolume and the PVC is being created automatic     

### we create cert with openssl or vault(PKI)
+ in a folder called cert 
+ 
> openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout certs/domain.key -x509 -days 365 \
  -out certs/domain.crt \
  -subj "/C=US/ST=State/L=City/O=Company/CN=registry.local"

### we create a secret for the certs on kubernetes clutser 
> kubectl create secret tls registry-cert -n registry \
  --cert=./domain.crt \
  --key=./domain.key

#### Create Authentication
we create the auth with htpasswd
> docker run --rm --entrypoint htpasswd httpd:2 -Bbn admin testing > auth/htpasswd

### we create a secret in k3s 
> kubectl create secret generic registry-auth -n registry \
  --from-file=./htpasswd

