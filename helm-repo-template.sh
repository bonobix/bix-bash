# ========================
# MinIO - Object Storage
# ========================
helm repo add minio https://charts.min.io
helm repo update
helm template minio minio/minio -n minio > minio.yaml

# ========================
# Prometheus Stack
# ========================
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm template kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring > prometheus.yaml

# ========================
# Argo CD - GitOps
# ========================
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm template argo-cd argo/argo-cd --version 7.7.3 -n argocd > argo-cd.yaml

# ========================
# Grafana
# ========================
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm template grafana grafana/grafana -n grafana > grafana.yaml

# ========================
# Ingress NGINX
# ========================
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm template ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx > ingress-nginx.yaml

# ========================
# Cert-Manager
# ========================
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm template cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true > cert-manager.yaml

# ========================
# External DNS
# ========================
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm template external-dns bitnami/external-dns -n external-dns > external-dns.yaml

# ========================
# Loki Stack
# ========================
helm template loki grafana/loki-stack -n loki > loki.yaml

# ========================
# Fluent Bit
# ========================
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update
helm template fluent-bit fluent/fluent-bit -n fluentbit > fluent-bit.yaml


#bootstrap
#!/bin/bash

# ===============================
# Step 1: Create required namespaces
# ===============================
echo "🔧 Creating namespaces..."
for ns in minio monitoring argocd grafana ingress-nginx cert-manager external-dns loki fluentbit; do
  kubectl get ns "$ns" >/dev/null 2>&1 || kubectl create ns "$ns"
done

# ===============================
# Step 2: Install CRDs
# ===============================
#Use kubectl create instead of kubectl apply otherwise you get this error: The CustomResourceDefinition "" is invalid: metadata.annotations: Too long: may not be more than 262144 bytes
echo "📦 Applying cert-manager CRDs..."
kubectl create -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml

echo "📦 Applying kube-prometheus-stack CRDs..."
# List of Prometheus Operator CRDs
CRDS=(
  alertmanagers
  podmonitors
  probes
  prometheuses
  prometheusrules
  servicemonitors
  thanosrulers
)

for crd in "${CRDS[@]}"; do
  kubectl create -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_${crd}.yaml"
done

echo "📦 Applying Argo CD CRDs..."
# Pull and extract Argo CD CRDs using helm
helm pull argo/argo-cd --untar
kubectl create -f argo-cd/crds/

echo "✅ All CRDs installed!"

