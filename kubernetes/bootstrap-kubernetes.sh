#!/bin/bash

: <<'COMMENT'

Rende operativo il cluster kubernetes installando componenti come Helm, CNI, MetalLB, Gateway API, ArgoCD...etc pezzo per pezzo

COMMENT

#--------------------------------------------------------------------------------
#.HELM install con curl | bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#--------------------------------------------------------------------------------
#CANAL install per k8s networking

curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/canal.yaml -O
sudo kubectl apply -f canal.yaml
#modifica containerd .toml con SystemdCgroup = true
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

#--------------------------------------------------------------------------------
#MetalLB-install K8s Load Balancer

#https://cloudspinx.com/install-metallb-load-balancer-on-kubernetes-cluster/
#SET strict ARP to true in kube-proxy configmap 
# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system
# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest|grep tag_name|cut -d '"' -f 4|sed 's/v//')
echo $MetalLB_RTAG
mkdir ~/metallb && cd ~/metallb
wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml
kubectl apply -f metallb-native.yaml
#watch kubectl get all -n metallb-system
#kubectl get pods -n metallb-system --watch
#manifest per generare pool e advert del pool 
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.30-192.168.1.50
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
EOF

#--------------------------------------------------------------------------------
#INGRESS CONTROLLER install 
#https://kubernetes.github.io/ingress-nginx/deploy/

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
#controlla che il pod ingress sia in ascolto su 8443
#kubectl -n ingress-nginx exec -it <tuo-ingress-pod> -- netstat -tuln | grep 8443
#assicurati che il firewall sui nodi non blocchi la porta 8443
#sudo ufw allow from 192.168.1.0/24 to any port 8443 proto tcp

#--------------------------------------------------------------------------------
#GATEWAY API install 
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

#--------------------------------------------------------------------------------
#NGINX GATEWAY FABRIC install 
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.0.1" | kubectl apply -f -
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
kubectl wait --timeout=5m -n nginx-gateway deployment/ngf-nginx-gateway-fabric --for=condition=Available

#--------------------------------------------------------------------------------
#PROMETHEUS install
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring
kubectl get pods -n monitoring --watch

#--------------------------------------------------------------------------------
#GRAFANA/LOKI install
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace loki

#possibile aggiungere admin password o persistence
helm install loki grafana/loki-stack --namespace=loki --set grafana.enabled=true \
	--set grafana.service.type=ClusterIP
#--set grafana.adminPassword=admin \

#--------------------------------------------------------------------------------
#ARGOCD para Gitops
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd

