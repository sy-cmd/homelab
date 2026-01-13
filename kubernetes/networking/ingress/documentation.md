
### Ingress
+ ingress in k8s is a networking resource that manages the external access to our services within the cluster 
  +  It acts as a smart router or entry point that can route traffic to different services based on rules (like hostnames or URL paths), often using a reverse proxy (called an Ingress Controller) to implement those rules.
  
+ ingress helps us to solve the problem of exposing our apps to the outside world or outside the the cluster 
  + and it has a lot of features such as adding security 
  
ingress components 
+ Ingress Resource: a yaml file defining the specification of routing 
+ Ingres Controller: a component like ( Nginx, Traefik, AWS ) that watches the ingress resource and configures a load balancer or proxy 
+ load balancer 
 + before i can use ingress i need to make sure i have ingress controller installed on the cluster 
 
steps 
1. we create an ingress controller 
2. ingress controller will watch for the ingress resources 
3. loadbalancer is created 

ingressClassName 
+ found in the spec and its used the select the controller that we want to use on a specific ingress 
+ its important to have different ingressClassName for our our cluster we might have different ingress that might be crushing when we don't select a classname.
+ to check if i have any ingress controllers installed `kubectl get ingressclass`

why and where we can use ingress 
+ the purpose of ingress is that it as as a smart traffic controller the the cluster 
+ ingress understands whats being requested and makes decisions while nodePorts and loadbancers gets us in the cluster 

advantages of ingress 
+ costs and Rewsources Efficiency 
 + with ingress we can use one IP and router all the traffic to it ( its costly to host loadbalancers on cloud as each loadbalancer is billed and takes its own IP )
+ Smart Routing (Domains and Paths)
  + ingress allows us to host multiple websites on the same IP address. it looks at the host and redirects it to the destination 
+ Centralized SSL/TLS Termination
  + Instead of configuring HTTPS, uploading certificates, and managing secrets for every single microservice, you do it once at the Ingress level. Traefik can even talk to Let's Encrypt to automatically generate and renew SSL certificates for every app you deploy.
+ Middleware & "Edge" Features
  + since ingress sits and the middle of the cluster we can add this like ( basic authentication, Rate Limiting,)



when testing in our local machines loadBalancers operate better in cloude services , we turn our ingress to use a NodePort instead of loadbalancer 

>  Delete the problematic svclb DaemonSet
`kubectl delete daemonset svclb-traefik-a71032e5 -n kube-system`

 Patch the Traefik service to use NodePort
 `kubectl patch svc traefik -n kube-system -p '{"spec":{"type":"NodePort"}}'`

 Check the new ports assigned
 `kubectl get svc traefik -n kube-system`

to access the the apps we use  
curl -H "Host: myapp.local" http://<NODE_IP>:30802
curl -H "Host: frontend.example.com" http://<NODE_IP>:30802
curl -H "Host: frontend.example.com" http://192.168.43.127:30802

to aceess the apps in my browser i need to update the `etc/host` and add the name of the app and their IPs
> sudo nano /etc/hosts
#####  Add these lines (replace with your actual node IP):
<NODE_IP>  myapp.local
<NODE_IP>  frontend.example.com
<NODE_IP>  api.example.com
192.168.43.127 frontend.example.com