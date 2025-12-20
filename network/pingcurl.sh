#!/bin/bash

: <<'COMMENT'

esegue curl con output in stile ping, utile per testare Load Balancer

COMMENT



while true; do
    echo -n "$(date '+%H:%M:%S') - "
    curl -k -s https://192.168.1.120:8123/bo
    sleep 1
done
