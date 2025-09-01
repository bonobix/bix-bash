# ========================
# MinIO - Object Storage
# ========================
helm repo add minio https://charts.min.io
helm repo update
kubectl create ns minio
helm install minio minio/minio -n minio

# ========================
# Prometheus - Monitoring
# ========================
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack

# ========================
# Argo CD - GitOps
# ========================
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create ns argocd
helm template argo/argo-cd --version 7.7.3 -n argocd

# ========================
# Grafana - Dashboards
# ========================
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create ns grafana
helm install grafana grafana/grafana -n grafana

# ========================
# NGINX Ingress Controller
# ========================
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx

# ========================
# Cert-Manager - TLS Certificates
# ========================
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create ns cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

#alternative from: https://cert-manager.io/docs/installation/helm/
#helm repo add jetstack https://charts.jetstack.io --force-update
#helm install \
#  cert-manager jetstack/cert-manager \
#  --namespace cert-manager \
#  --create-namespace \
#  --version v1.17.2 \
#  --set crds.enabled=true

# ========================
# External DNS - Auto DNS updates
# ========================
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns external-dns
helm install external-dns bitnami/external-dns -n external-dns

# ========================
# Loki - Logs aggregation
# ========================
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create ns loki
helm install loki grafana/loki-stack -n loki

# ========================
# Fluent Bit - Log forwarder
# ========================
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
kubectl create ns fluentbit
helm install fluent-bit fluent/fluent-bit -n fluentbit

