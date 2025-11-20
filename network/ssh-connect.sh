#!/bin/bash

: <<'COMMENT'

Output di una lista host a cui connettersi tramite ssh

esempio di file .ssh/config con cui questo script lavora:
#Host <tuo-hostname> 
#    HostName <tuo-hostname>
#    User <tuo-user>
#    IdentityFile ~/.ssh/id_rsa
#    IdentitiesOnly yes

COMMENT

# Verifica se il file ~/.ssh/config esiste
CONFIG_FILE="$HOME/.ssh/config"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Il file $CONFIG_FILE non esiste."
  exit 1
fi

# Estrae gli host dal file di configurazione, escludendo quelli con wildcard
HOSTS=($(grep -E "^Host\s+" "$CONFIG_FILE" | grep -v '\*' | awk '{print $2}'))

# Verifica se sono stati trovati host
if [ ${#HOSTS[@]} -eq 0 ]; then
  echo "Nessun host trovato nel file $CONFIG_FILE."
  exit 1
fi

# Mostra l'elenco degli host
echo "Seleziona un host SSH:"
for i in "${!HOSTS[@]}"; do
  echo "$((i+1))) ${HOSTS[$i]}"
done

# Richiede all'utente di selezionare un host
read -p "Inserisci il numero dell'host: " SELECTION

# Verifica se l'input è un numero valido
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#HOSTS[@]}" ]; then
  echo "Selezione non valida."
  exit 1
fi

# Ottiene l'host selezionato
SELECTED_HOST="${HOSTS[$((SELECTION-1))]}"

# Connette all'host selezionato
echo "Connessione a $SELECTED_HOST..."
ssh "$SELECTED_HOST"
