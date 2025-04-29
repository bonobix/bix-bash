#gateway-api install for missing crds
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

#expose, NodePort
kubectl expose deployment <name> --type=NodePort --name=<service-name> --port=<port> --target-port=<port>

#expose, NodePort
kubectl expose <resource> --type=NodePort --name=<service-name>

#install-kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

#kuztomize, nginx
mkdir nginx-ingress && cd nginx-ingress
kustomize create --resources https://github.com/kubernetes/ingress-nginx/deploy/static/provider/cloud/
kubectl apply -k .
