#!/bin/bash

: <<'COMMENT'

Crea Template da usare per creare VM

COMMENT

qm create 9991 --name "template-ubuntu-2204-cloudinit" \
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
  --net0 virtio,bridge=vmbr1

# Convert to template.
qm template 9991
