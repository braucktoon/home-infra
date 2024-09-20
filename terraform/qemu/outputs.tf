output "plex_vm_id" {
  value = proxmox_vm_qemu.plex_vm.vmid
}

output "vm_id" {
  value = proxmox_vm_qemu.pihole_vm.vmid
}