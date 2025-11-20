#!bin/bash

: <<'COMMENT'

fa il patch di un deploy,
in questo esempio vengono patchati i deploy di argocd modificando il numero di repliche

COMMENT

for ns in argocd ; do
  for deploy in $(kubectl get deployments -n $ns -o jsonpath='{.items[*].metadata.name}'); do
    echo "Patching $deploy nel namespace $ns"
    kubectl patch deployment $deploy -n $ns \
      --type=merge -p '{"spec":{"replicas":1}}'
  done
done
