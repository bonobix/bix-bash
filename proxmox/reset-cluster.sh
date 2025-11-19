#!bin/bash


: <<'COMMENT'

Da eseguire sul nodo dove si è creato il cluster per rimuovere il cluster

COMMENT


systemctl stop pve-cluster
systemctl stop corosync
rm -rf /etc/pve/corosync.conf
rm -rf /etc/corosync/*
rm -rf /var/lib/pve-cluster/*
