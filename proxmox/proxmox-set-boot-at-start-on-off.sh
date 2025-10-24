#!/bin/bash
#imposta start al boot delle vm su un host proxmox
echo "==== Proxmox VM Boot Config Script ===="

# Chiede range di VM
read -p "Inserisci VM ID iniziale: " start
read -p "Inserisci VM ID finale: " end

# Chiede azione
read -p "Vuoi abilitare (on) o disabilitare (off) lo start automatico? [on/off]: " action

if [[ "$action" != "on" && "$action" != "off" ]]; then
    echo "Azione non valida. Uscita."
    exit 1
fi

# Loop sul range
for vmid in $(seq $start $end); do
    if qm list | awk '{print $1}' | grep -q "^$vmid$"; then
        if [ "$action" == "on" ]; then
            qm set $vmid --onboot 1
            echo "VM $vmid: start on boot ENABLED ✅"
        else
            qm set $vmid --onboot 0
            echo "VM $vmid: start on boot DISABLED ❌"
        fi
    else
        echo "VM $vmid non esiste, salto..."
    fi
done

echo "==== Operazione completata ===="
