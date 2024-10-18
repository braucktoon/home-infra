resource "proxmox_vm_qemu" "vm" {
  depends_on = [ null_resource.cloud_init_transfer ]

  name        = var.name
  target_node = var.node
  clone       = var.template  # Name of the cloud-init template

  cores       = var.cores
  memory      = var.memory
  sockets     = var.sockets
  scsihw      = "virtio-scsi-pci"
  bios        = "ovmf"
  agent       = 1

  disks {
    virtio {
      virtio0 {
        disk {
          size    = var.disk_size
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type    = "cloud-init"
  cicustom   = "vendor=local:snippets/${var.cloud_init_filename}"
  ciuser     = "${var.ciuser}"
  ipconfig0  = "ip=${var.ip_address}/24,gw=${var.gateway_ip}"  # Configure IP using cloud-init
  nameserver = var.nameserver

  sshkeys = var.ssh_keys

  boot = "order=virtio0"    
}

# Render the template file using the built-in templatefile() function
locals {
  cloud_init_content = templatefile("${path.module}/${var.cloud_init_tpl_filename}", {
    keepalived_auth_type = var.cloud_init_vars.keepalived_auth_type
    keepalived_pass      = var.cloud_init_vars.keepalived_pass
    pihole_ip            = var.cloud_init_vars.pihole_ip
    pihole_vip           = var.cloud_init_vars.pihole_vip
    secondary_pihole_ip  = var.cloud_init_vars.secondary_pihole_ip
    nas_ip               = var.cloud_init_vars.nas_ip
  })
}

# Write the rendered content to a local file
resource "local_file" "cloud_init" {
  content  = local.cloud_init_content
  filename = "${var.cloud_init_local_path}"
}

# Use null_resource to transfer cloud-init templates
resource "null_resource" "cloud_init_transfer" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = var.pve_ip
  }

  provisioner "file" {
    source      = var.cloud_init_local_path
    destination = "/var/lib/vz/snippets/${var.cloud_init_filename}"
  }
}
