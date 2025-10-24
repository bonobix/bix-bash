#!/bin/bash

: <<'COMMENT'

Crea Vm partendo da un template, bisogna cambiare le variabili per soddisfare quelle che sono le esigenze.

COMMENT

TEMPLATE_ID=9990                  # ID della cloud-init template VM
BASE_IP="192.168.1"            # Prefisso rete
GATEWAY="<VM-gateway>"       # Specifica Gateway 
BRIDGE="vmbr0"
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Range di VMID da creare
START=3033 
END=3033

# Loop di creazione
for VMID in $(seq $START $END); do
    IP="$BASE_IP.$VMID"
    NAME="vm$VMID"

    echo "🛠️  Creazione VM $VMID con IP $IP..."

    qm clone $TEMPLATE_ID $VMID --name $NAME --full true

    qm set $VMID \
        --ipconfig0 ip=${IP}/24,gw=$GATEWAY \
        --nameserver 1.1.1.1 \
        --sshkey "$SSH_KEY" \
        --net0 virtio,bridge=vmbr0 \
        --hostname $NAME
    qm start $VMID
    echo "VM $VMID ($NAME) pronta con IP $IP!"
    echo "---------------------------------------------"
done
