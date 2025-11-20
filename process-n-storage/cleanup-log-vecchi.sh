#!/bin/bash
# Script: clean_logs.sh
# Scansione del filesystem /var/log e rimuove log più vecchi di 30 giorni

LOG_DIR="/var/log"
DAYS=30

echo "[$(date +'%F %T')] Avvio cleanup logs in ${LOG_DIR}, > ${DAYS} giorni"
find "$LOG_DIR" -type f -name "*.log" -mtime +"${DAYS}" -print -exec rm -f {} \;

echo "[$(date +'%F %T')] Cleanup logs completato"

# Pulire log vecchi di 7 giorni
# find /var/log -type f -mtime +7 -delete
