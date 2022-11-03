#!/usr/bin/env bash

echo "* killing port forwarding to argocd ui"
pid=$(ps -ef | grep port-forward | grep argocd-server | cut -d" " -f 3)
[[ ${pid} ]] && kill ${pid}

# echo "* deleting all objects"
# kubectl delete deployments,services,pods,daemonset,jobs --all

echo "* deleting ns/argocd ... NOTE: this will take a little while"
argocdns=$(kubectl get ns | grep argocd)
[[ ${argocdns} ]] && kubectl delete ns/argocd

echo "* resetting kubectl context back to default"
kubectl config set-context --current --namespace=default

echo "* list of objects"
kubectl get deployments,services,pods,daemonset,jobs
