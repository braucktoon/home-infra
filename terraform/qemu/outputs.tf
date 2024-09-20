output "plex_vm_id" {
  value = proxmox_vm_qemu.plex_vm.vmid
}

output "pihole_vm_id" {
  value = proxmox_vm_qemu.pihole_vm.vmid
}

output "arrs_vm_id" {
  value = proxmox_vm_qemu.arrs_vm.vmid
}
