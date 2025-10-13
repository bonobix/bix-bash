#!bin/bash


for ns in argocd ; do
  for deploy in $(kubectl get deployments -n $ns -o jsonpath='{.items[*].metadata.name}'); do
    echo "🔄 Patching $deploy nel namespace $ns"
    kubectl patch deployment $deploy -n $ns \
      --type=merge -p '{"spec":{"replicas":1}}'
  done
done
