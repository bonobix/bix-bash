#!/bin/bash
#invia alert in base al numero di Pod
POD_COUNT=$(kubectl get pods -A -o name | wc -l)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

logger -t check-pod "$TIMESTAMP - Pod attivi: $POD_COUNT"

if [ "$POD_COUNT" -gt 30 ]; then
    logger -t check-pod "$TIMESTAMP - ALERT: Troppi pod attivi ($POD_COUNT)"
elif [ "$POD_COUNT" -lt 20 ]; then
    logger -t check-pod "$TIMESTAMP - ALERT: Troppi pochi pod attivi ($POD_COUNT)"
fi
