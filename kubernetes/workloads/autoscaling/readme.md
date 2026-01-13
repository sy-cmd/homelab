
### Autoscaling 
+ is changing the the workload to meet the demand.
   
#### horizontal pod autoscaling 
+ it automatically added more pods to the node if the demand get high , it replicates the pods to meet the demand  
+ we are always scale in/ out   according to the demand , MANAGED BY HPA
+ workloads(pods) and infra ( nodes ) cluster Autoscaler 
+ its the default autoscaling  we just need to have the metrics server where the HPA will get the metrics 

#### vertical pod autoscaling 
+ with vertical auto scaling it increases the resources of the pod and mostly the pods are stateless in nature cause the pod needs a restart after
+ here we are always scale up or down of the resources  
+ works on:
  +  workloads (pods) VPA
  +  infra (nodes) its managerd by Node AutoProvisioning which is found on the cloud infra
+  

commands 
+ how to enbale auto scale on a deployment and it look for a 50% usage within the deployment and if the app exceeds the 50% the pods are increased and when the usage is below the 50% its reduced 
+ ` kubectl autoscale deploy $name-of-deployment  --cpu-percent=50  --min=1 max=10`

Health probes
+ probes is a background process that monitors the system and takes some actions to make sure that the process are health and running
+ these probes are part of containers  
   
types of probes and what they do 
+ liveness: restarts the application if it fails 
+ readiness: it ensures that the app is ready before it can be accessed by the uses 
+ startup: for low/legacy ( we use these )
+ health: checks for tcl,https etc 
