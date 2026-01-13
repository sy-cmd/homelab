how to delete 
### longhorn 
> kubectl get namespace longhorn-system -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/longhorn-system/finalize" -f -
we need to make sure ISCSI is running 
### install with helm charts 
1. Add Longhorn chart repository.
   + `helm repo add longhorn https://charts.longhorn.io`
2. Update local Longhorn chart information from chart repository.
  + `helm repo update`
3. we create the longhorn namespace and install in that namespace 
> kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system

4. to uninstall 
> kubectl -n longhorn-system patch -p '{"value": "true"}' --type=merge lhs deleting-confirmation-flag
helm uninstall longhorn -n longhorn-system
kubectl delete namespace longhorn-system