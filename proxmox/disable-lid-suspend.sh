#!/bin/bash

: <<'COMMENT'

script utile quando si usa Proxmox su un portatile, disabilita il suspend automatico del portatile quando si chiude il Lid,
di base i comandi da eseguire sono questi:
vim /etc/systemd/logind.conf
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
systemctl restart systemd-logind

COMMENT



set -e

CONF="/etc/systemd/logind.conf"

echo ">> Disabilito suspend sul lid…"

# Backup
cp "$CONF" "${CONF}.bak.$(date +%s)"

# Aggiorno la configurazione
sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=ignore/' "$CONF"
sed -i 's/^#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' "$CONF"
sed -i 's/^#\?HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' "$CONF"

# Se mancano le voci le aggiunge
grep -q '^HandleLidSwitch=' "$CONF" || echo "HandleLidSwitch=ignore" >> "$CONF"
grep -q '^HandleLidSwitchExternalPower=' "$CONF" || echo "HandleLidSwitchExternalPower=ignore" >> "$CONF"
grep -q '^HandleLidSwitchDocked=' "$CONF" || echo "HandleLidSwitchDocked=ignore" >> "$CONF"

# Applica
systemctl restart systemd-logind

echo ">> Fatto! Ora puoi chiudere il lid senza mettere a nanna il server."
