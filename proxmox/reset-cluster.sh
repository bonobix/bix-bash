#!bin/bash


: <<'COMMENT'

Da eseguire sul nodo dove si è creato il cluster per rimuovere il cluster

COMMENT

#prima esegui pvecm delnode NOME_NODO su ogni nodo tranne quello da cui ricrei il cluster

systemctl stop pve-cluster
systemctl stop corosync
rm -rf /etc/pve/corosync.conf
rm -rf /etc/corosync/*
rm -rf /var/lib/pve-cluster/*
