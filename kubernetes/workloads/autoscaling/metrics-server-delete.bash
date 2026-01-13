#!/bin/sh
# to delete metrics-server from a Kubernetes cluster
kubectl delete -n kube-system deployment metrics-server
kubectl delete -n kube-system service metrics-server
kubectl delete apiservice v1beta1.metrics.k8s.io
kubectl delete -n kube-system serviceaccount metrics-server
kubectl delete clusterrole system:aggregated-metrics-reader
kubectl delete clusterrole system:metrics-server
kubectl delete -n kube-system rolebinding metrics-server-auth-reader
kubectl delete clusterrolebinding metrics-server:system:auth-delegator
kubectl delete clusterrolebinding system:metrics-server