#!/bin/bash

"""

installa gateway API, kustomize e fai deploy di un Ingress nginx

Installi Gateway API per abilitare la nuova API standard Kubernetes
- Deploy INGRESS per gestire concretamente il traffico
- Entrambi servono per coesistere durante la transizione Ingress → Gateway

"""

set -e

# Installa Gateway API
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

# Installa kustomize
if ! command -v kustomize &> /dev/null; then
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  sudo mv kustomize /usr/local/bin/
fi

# Deploy nginx ingress
mkdir -p nginx-ingress && cd nginx-ingress
kustomize create --resources https://github.com/kubernetes/ingress-nginx/deploy/static/provider/cloud/ || true
kubectl apply -k .

echo "Gateway API presente & NGINX ingress pronto all'uso !"
