#!/bin/bash

: <<'COMMENT'

Rende operativo il cluster kubernetes installando componenti come MetalLB, Gateway API...etc

COMMENT

#--------------------------------------------------------------------------------
#DOCKER install 
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
docker --version
sudo usermod -aG docker $USER
newgrp docker

#--------------------------------------------------------------------------------
#KUBERNETES install 

#carica moduli kernel necessari
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
#sysctl config
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
#applica le modifiche
sudo sysctl --system
#1. Rimuovi il vecchio repository
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
#2. Aggiungi la chiave GPG del nuovo repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
#3. Aggiungi il nuovo repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
#--------------------------------------------------------------------------------
#CONTAINERD install

sudo apt install containerd -y
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
containerd --version
sudo ctr version
sudo ctr images pull docker.io/library/alpine:latest
#--------------------------------------------------------------------------------
#HELM install

sudo apt-get install -y apt-transport-https && \
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - && \
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
sudo apt-get update && sudo apt-get install -y helm


#--------------------------------------------------------------------------------
#CANAL install per k8s networking

curl https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/canal.yaml -O
sudo kubectl apply -f canal.yaml
#modifica containerd .toml con SystemdCgroup = true
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
#inizializza il master
kubectl init
#da passare come root dopo kubeadm init 
export KUBECONFIG=/etc/kubernetes/admin.conf
#install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
#install traefik ingress controller
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik --namespace traefik --create-namespace \
  --set ingressClass.enabled=true \
  --set ingressClass.isDefaultClass=true \
  --set service.type=NodePort \
  --set dashboard.enabled=true \
  --set dashboard.ingress.enabled=true \
  --set dashboard.ingress.hosts[0]=traefik.local




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
