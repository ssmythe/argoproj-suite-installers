#!/usr/bin/env bash

echo "* kubectl applying resources"
kubectl create namespace argocd
kubectl config set-context --current --namespace=argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "* sleeping 20 seconds to let things warm up"
sleep 20

if [[ ! -f "/usr/local/bin/argocd" ]]; then
    echo "* installing argocd cli (as root)"
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
else
    echo "* installing argocd cli - skipping, already installed"
fi

echo "* patching argocd-server"
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "* port forwarding for svc/argocd-server (localhost:8081)"
kubectl port-forward svc/argocd-server -n argocd 8081:443 2>&1 1>/dev/null &

echo "* argocd admin password"
export ARGOCD_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "* argocd version"
argocd version

echo "* logging in to argocd with admin and the above password"
argocd login --insecure localhost --username admin --password ${ARGOCD_ADMIN_PASSWORD}

echo "* login to argocd UI with admin and the following password"
echo "${ARGOCD_ADMIN_PASSWORD}"
