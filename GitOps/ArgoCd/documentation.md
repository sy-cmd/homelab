# GitOps 
+ is a set of practices where the entire state of our infrastructure is store in git , git because our source of truth for our infrastructure 
## Argo Cd 
Argo CD is a declarative, continuous delivery tool for Kubernetes

### The Core Concept: GitOps 
+ To understand Argo CD, you must understand GitOps.
Traditional CD (Push): Your CI server (like Jenkins) builds code, logs into your Kubernetes cluster, and runs kubectl apply. The CI server holds the power.
+ GitOps (Pull): You commit code/configuration to Git. Argo CD (running inside Kubernetes) watches that Git repository. When it sees a change, it pulls the changes and applies them to the cluster.

### Why Argo CD?
Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

### Why Should You Use It
+ Single Source of Truth: You never manually run kubectl edit on a production cluster. Everything is defined in Git. If the cluster dies, you can rebuild it exactly as it was just by pointing Argo CD at the repo.
+ Drift Detection & Auto-Healing: If someone manually changes a configuration in the cluster (causing "drift"), Argo CD detects that the live state differs from Git. It can automatically revert the change to match Git.
+ Easy Rollbacks: Did a deployment break the app? Don't panic. Simply revert the Git commit. Argo CD sees the revert and rolls back the application automatically.
+ Security: Your CI pipeline (GitHub Actions, Jenkins) does not need access to your Kubernetes cluster credentials. It only needs permission to push to Git. Argo CD holds the cluster credentials, reducing the attack surface.
+ Visual Dashboard: Argo CD provides a beautiful UI that shows the health status of every resource, making debugging much easier than staring at CLI logs.

## Installation
On k8s or k3s cluster  
```
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
CLI
```
we download the file 
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

### we make it executable
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

we remove the binary we just got from github 
rm argocd-linux-amd64
```
+ to make the system recognize the shortcut way of running `kubectl get pods -n argocd`
 + we use `kubectl config set-context --current --namespace=argocd`

### After installing of Argo CD
It is not exposed out side of the cluster we need to create a service for it and expose it to the outside world 
Loadbalancer 
+ `kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`
Port Forwarding
+ `kubectl port-forward svc/argocd-server -n argocd 8080:443`

### we need to login in 
+ initializing the password 
 + `argocd admin initial-password -n argocd`
+ we can later update the password with 
 + `argocd account update-password`

Login
+ we can login with the username `admin` and the password we got from the initializing 
  + `argocd login <ARGOCD_SERVER>`



### Networking 

we need to make sure theall pods all running for atgocd to be able to communicate with repos 
+ `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server` 

