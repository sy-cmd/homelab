### Services, Load Balancing, and Networking
+ The Kubernetes network model is built out of severals pieces:
   + each pod in cluster gets its own unique cluster-wide ip address( a pod has its own private network and all the processes or apps communicate through the localhost )
   + Pod network or cluster network it handles communication between pods. all pods comminate with other pods weather they are on the same node or not without needing the use of proxies or nat 
   + Service api lets have a stable Ip address or hostname for our pods ,since with normal development pods can change overtime 
   + Gateway api (or ingress ) it allows us to make the services accessible to clients out side the cluster.
   + Network Policy is built-in kubernetes api that allows me to control traffic between pods and the out side worlds

### Service
+ Service is a method of exposing the network of running pods either one or more . 
+ it gives us the ability to have a unique and stable  ip address and Dns which can be used for communication for other services in the cluster 
service types 
+  ClusterIP -- it exposes the service on an internal ip and can be accessed within the cluster ,its the default if we don't specify any service type 
  + used for internal communications ( its mostly the default )
+  NodePort -- it exposes the service on the nodes IP on a static port
   + this is used when we don't have a loadbalancer and we want to test the app we can use it for debugging and exposing it outside the cluster  
+  LoadBalancer -- it exposes the services to clients out side the cluster.
+  ExternalName -- Maps the Service to the contents of the externalName field (for example, to the hostname api.foo.bar.example). The mapping configures your cluster's DNS server to return a CNAME record with that external hostname value. No proxying of any kind is set up.
  + it creates the Dns name that can be used outside the cluster 