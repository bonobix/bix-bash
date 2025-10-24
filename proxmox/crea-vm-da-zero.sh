#!/bin/bash

#----------------------------------
# Create multiple VMs from scratch.
#----------------------------------
# Description:
#   Provision multiple VMs from scratch (no template).
#   Configure VM cloud-init settings (ip, dns, gw etc).

# Variables
startVMID=114
vmList=(
        "tst-svr-mgt02"
        "tst-svr-pwm02"
        "tst-svr-mon02"
)
for vm in ${!vmList[@]}; do
  echo "Creating VM ${vm}: ${vmList[$vm]} (${startVMID})"

  qm create ${startVMID} --name "${vmList[$vm]}" \
  --ostype l26 \
  --memory 1024 --balloon 0 \
  --agent 1 \
  --bios seabios \
  --boot order=scsi0 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:0,import-from=/var/lib/vz/template/iso/ubuntu-22.04-cloudimg-amd64.img,backup=0,cache=writeback,discard=on \
  --ide2 local-lvm:cloudinit \
  --cpu host --socket 1 --cores 1 \
  --vga virtio \
  --net0 virtio,bridge=vmbr0

# Set VM network config, interating the IP address using "vm" counter variable.
  qm set ${startVMID} --ipconfig0 "ip=192.168.1.1${vm}/24,gw=192.168.1.1"
  qm set ${startVMID} --nameserver="192.168.1.1 8.8.8.8"
  qm set ${startVMID} --searchdomain="infra"
  qm set ${startVMID} --sshkey ~/.ssh/id_rsa.pub
  echo "Complete: ${vmList[$vm]}"
  echo ""
  ((startVMID++))
done
