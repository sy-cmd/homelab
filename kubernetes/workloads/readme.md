### workloads
+ a workload is an application running on kubernetes, weather its a single app or group that work together. in kubernetes applications run in pods 
+ pod is a smallest unit that represents a running container in a cluster .

Kubernetes provides several built-in workload resources:
+ Deployment -- its the easy way of deploying application that don't need persistent storage or stateLess workloads 
+ StatefulSet -- is a workload api object used to manage stateful applications, its makes sure that each pod has stable and persistent identity , consistent storage mostly used for databases 
+ DaemonSet --- the purpose of a demonset is to make sure that a copy of a specific pod runs on all eligible nodes in a cluster. if the specification matches the one in the deamonSet the control plane makes sure that it runs the pods in those nodes ( it can be configuring a network in a cluster )
+ Job and CronJob -- jobs defines tasks that runs once and stop. we can use cronjobs to run the same jobs multiply times


### Deployment ( stateless applications)
+ we use deployment to deploy stateless application. we can also create replicas depending to the ones we specified in our file ( yaml)
+ to check the deployments -- `kubectl get deployments` or `kubectl get deploy`
+ to check rollout status -- `kubectl rollout status`
+ to see the replicaset created -- `kubectl get rs.`
+ to edit a deployed file -- `kubectl edit deployment/$name-of-file`
+ we can get the details of deployed app with -- `kubectl describe deployments`
+ to see the details of each revision -- `kubectl rollout history deployment/nginx-deployment --revision=2`
+ we can scale deployment with -- `kubectl scale deployment/nginx-deployment --replicas=10`
+ if horizontal pod autoscalling is enabled i can specify the number of pods that run depending to my cpu -- `kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80`
+ i can update the image with -- `kubectl set image deployment/nginx-deployment nginx=nginx:sometag`
+ to delete a deployment we use --- `kubectl delete deployment $name `

Deployment( stateful application  )
+ we create a pvc file that has the persistent volume claim for our files 
+ we run the deployment as service so that it can be accessed my any pod in our cluster 
+ we can access mysql with `kubectl run -it --rm --image=mysql:9 --restart=Never mysql-client -- mysql -h mysql -ppassword`
+ we don't scale app that are running under statefulSet 
+ we use the recreate strategy which stops the same instance and creates a new one in k8s we can not have two instance with the same name 
+ to delete pvc -- `kubectl delete pvc mysql-pv-claim`
+ to delete pv -- `kubectl delete pvc mysql-pv-claim`

#### Replication controller or replicaSet 
+ its responsible for running the same pod by replicating it 
+ and its responsible for running a pod when it crushes or dies ( fails  ) depending with the replicas we stated in our  replica object 
+ we can get replicaSet with `kubectl get rc` and its only used to manage the pods that where created with it 
ReplicaSet 
+ with it we can set the app that we want to be part or managed the the replicaSet 
+ to get the replicaSet we use `kubectl get rs`
  + Pods that are not managed by the  replicaSet , when they die the kubelet looks at what restart policy we have and the default is always restart it tries to restart it 

### Deployment
Deployment  
+ it manages applications and scale apps according to our configuration
+  
#### CronJObs
+ these run once and we use cronjobs to schedule them 
+ `kubectl get cronjob $name of cronjob `
+ to watch the jobs -- `kubectl get jobs --watch`
+ to delete a cronjob `kubectl delete cronjob hello`

### DaemonSet 
+ daemonSet adds a copy of a pod to the nodes on the cluster if they meet the requirements. when ever we have new nodes added to the cluster deamonSet checks if they are eligable and adds a copy of the pods to them. sudo apt install antigravity
+ when we delete these nodes the copies that were added to them are kept as garbage and deleting a daemonSet deletes all its pods 
+ Some typical uses of a DaemonSet are:
 + running a cluster storage daemon on every node
 + running a logs collection daemon on every node
 + running a node monitoring daemon on every node
 + basically we use it when we want to run something in each of the nodes or selected number of nodes such as running a monitoring agent or a logging agent 
