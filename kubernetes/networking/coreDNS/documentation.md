### DNS IN KUBERNETES 
+ Domain name system 
+ this file contains the Ip address of my DNS servers such as coreDNS `etc/resolv.conf`
+ for the hosts that we connect too and the machine checks this file before it can ask the network  `etc/hosts`

how we use them 

#### ping, curl , Browsers 
+ these check the */ect/hosts* before they can ask the servers in our servers.

#### dig, nslookup, host
+ these they go direct to the servers */etc/resolv.conf*

#### CoreDNS in kubernetes
+ CoreDNS is a general-purpose authoritative DNS server that can serve as cluster DNS, complying with the
  + which helps in querying and creating a dns record for the new pods 
  + its primary job is service discovery 
  + this only works in pods we need to be inside pods to be able to check and verfly the pods can reach other services through their DNS

Namespaces of Services
+ a dns query may return different results based on the namespace of the pod 
+ we can access pods in different name spaces by specifying them , if we don't it brings the default 

DNS Records 
the coreDNS records objects such as 
by default pods don't get DNS names , only services . however if pods have a headless service ( with no ip they do get service name ), and if am using a statefulSet  
+ services 
+ pods 

Naming 

Services
+ A/AAAA records--Normal" (not headless) Services are assigned DNS A and/or AAAA records, depending on the IP family or families of the Service, with a name of the form
  + my-svc.my-namespace.svc.cluster-domain.example eg `vault.vault.svc.cluster.local

+ SRV records -- these are created from named ports that are part of the normal or headless service.
  + _port-name._port-protocol.my-svc.my-namespace.svc.cluster-domain.example

Pods
kube-DNS
A/AAAA records -- 
+ <pod-IPv4-address>.<namespace>.pod.<cluster-domain>
   + For example, if a Pod in the default namespace has the IP address 172.17.0.3, and the domain name for your cluster is cluster.local, then the Pod has a DNS name:
   + *172-17-0-3.default.pod.cluster.local*

coreDNS
+ <pod-ipv4-address>.<service-name>.<my-namespace>.svc.<cluster-domain.example>
  + For example, if a Pod in the cafe namespace has the IP address 172.17.0.3, is an endpoint of a Service named barista, and the domain name for your cluster is cluster.local, then the Pod would have this service-scoped DNS A record
  + *172-17-0-3.barista.cafe.svc.cluster.local*
