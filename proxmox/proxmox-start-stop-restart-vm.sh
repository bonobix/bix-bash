#!/bin/bash

# Chiede il range di VM
read -p "Inserisci il range di VM (es. 160-166): " RANGE
read -p "Azione da eseguire (start, stop, restart): " ACTION

# Estrae l'inizio e la fine del range
START=$(echo $RANGE | cut -d '-' -f1)
END=$(echo $RANGE | cut -d '-' -f2)

# Controllo base su azione valida
if [[ "$ACTION" != "start" && "$ACTION" != "stop" && "$ACTION" != "restart" ]]; then
    echo "Azione non valida!"
    exit 1
fi

# Ciclo sulle VM
for i in $(seq $START $END); do
    echo "Eseguendo $ACTION sulla VM $i..."
    qm $ACTION $i
done

echo "Operazione completata!"
