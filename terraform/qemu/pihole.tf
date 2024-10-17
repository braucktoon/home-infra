# Render the template file using the built-in templatefile() function
locals {
  pihole_cloud_init_content = templatefile("${path.module}/pihole-cloud-init.tpl", {
    keepalived_auth_type = var.keepalived_auth_type
    keepalived_pass      = var.keepalived_pass
  })
}

# Write the rendered content to a local file
resource "local_file" "pihole_cloud_init" {
  content  = local.pihole_cloud_init_content
  filename = "${path.module}/files/pihole-cloud-init.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "pihole_cloud_init" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "10.0.0.16"
  }

  provisioner "file" {
    source      = local_file.pihole_cloud_init.filename
    destination = "/var/lib/vz/snippets/pihole_cloud_init.yml"
  }
}

resource "proxmox_vm_qemu" "pihole_vm" {
  depends_on = [ null_resource.pihole_cloud_init ]
  name        = "pihole-vm"
  target_node = "pve"
  clone       = "debian-12-template"  # Name of your cloud-init template

  cores       = 2
  memory      = 2048
  sockets     = 1
  scsihw      = "virtio-scsi-pci"
  bios        = "ovmf"
  agent       = 1

  disks {
    virtio {
        virtio0 {
            disk {
                size = 32
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
    model     = "virtio"
    bridge    = "vmbr0"
  }

  os_type    = "cloud-init"
  cicustom   = "vendor=local:snippets/pihole_cloud_init.yml"
  ciuser     = "pihole"
  ipconfig0  = "ip=10.0.0.17/24,gw=10.0.0.1"  # Configure IP using cloud-init
  nameserver = "1.1.1.1"

  sshkeys = <<EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4o/s7abXCP8bN4csqJ89boo3AAOS7fbSoFB0OxjEwIVdUvwXijCnlYrqT5eBdft4yy3SY2RJ3pa+2JNbC6FFqGuEu7HudLiCY0qfoxVD6O6Ds3h5C4Wn3eaQ6tWqE+mn3jQs5Aj3n16/qB1oTr9Pw2+mhuTO1gCjop0U3K8vlQuWUQlQhlTYf977qEejfL7IwJHaNcJQIUUBgrR3b8VCe1EBa5C0CLutxAKRRpmv80EkkEKULUYdV9Klg3DXeZYNyBXBfPm8YZMJhtpnJ6xMTzzGlqjuoOPiqDqlw0SyhpplzaZLjKcG6urF7wgmvQdIpi5GKmdWundXKOETaC/1R davidmcgough@Davids-iMac.home
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbfXSyv6ugfAEBac79iqSIYI9BDyowe98RSlKlwLoPoImWefhKAzYEpk64TSqdItKK7td9Tbp6poPfiNvM3ZrBWU+pIWr2yGLvthF021R/1csQnSZjm6TNuIjwztaWfktZsiCwIK8bCAWy3ZUDDDvA0B93SswhqD7saR+WojRukGgIxc44wSGaw8Zp2h8CMh30ApozNCUG7pRfm/va7xm7WcJLYi3Fo1nR3BVqwyjPtMijb30QZ/Y9w9sH7UMW8XDJ/mBn0J4pECSCsiL57s/yr7MxVMXf+llxlf9Lh9+A3x0BTLYnWnZWe8oqmSNbZOYwsn1JlpF9wAThCuoe8YRPfGzby+kE4ZBB5ZfZvZeIW171pGMh1TVEzQhRSQA76Bdewt6n1vqhXiiEROnQX4iRjnd6y97pXFX1bwh++SZNZH9mAd/8Y92kzPg2wgk6ZJSrJ7O04Opa/h5Z5+a1LEB8F+HFTB+Jlu1w2hkWI8bIFcjepsM6BhIHat2cKIv3/oyKIKMx49YqG8T988WKj0vTZnaBAB3ZJiO50Ni4xkswUUwiPhI2ww5jbHZpAOvu4pNo1qLJAdDQxhPM5Uzea8oWxTgeeG/9WEy6NbNAJgn40CTzkJK9A7cnEjU5DbUY+1zlK3fRe+8xzPUCU757V5JdxX3sQgPi6umRdG1O2DoIgQ== root@pve
  EOF

  boot       = "order=virtio0"    

}