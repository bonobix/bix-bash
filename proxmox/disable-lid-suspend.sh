#!/bin/bash

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
