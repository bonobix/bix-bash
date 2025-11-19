systemctl stop pve-cluster
systemctl stop corosync
rm -rf /etc/pve/corosync.conf
rm -rf /etc/corosync/*
rm -rf /var/lib/pve-cluster/*
