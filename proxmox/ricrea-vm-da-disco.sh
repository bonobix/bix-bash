

#vedi il contenuto del disco
pvesm list <nome-disco>

#crea VM senza disco 
qm create <vm-id> --name <nome-vm> --memory 2048 --net0 virtio,bridge=<nome-bridge> --cores 2

#aggiungi immagine VM dal disco 
qm set <vm-id> --scsi0 <nome-disco>:<vm-id>/vm-..


#aggiungi cloudinit
qm set <vm-id> --ide2 <nome-disco>:<vm-id>/vm-..cloudinit

