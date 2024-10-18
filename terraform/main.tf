module "pihole_vm" {
  source                  = "./modules/vm"
  name                    = "pihole-vm"
  node                    = "pve"
  template                = "debian-12-template"
  cores                   = 1
  memory                  = 1024
  sockets                 = 1
  disk_size               = "32G"
  cloud_init_filename     = "pihole_cloud_init.yml"
  cloud_init_local_path   = "${path.module}/files/pihole-cloud-init.cfg"
  cloud_init_tpl_filename = "${path.module}/pihole-cloud-init.tpl"
  cloud_init_vars         = var.cloud_init_vars["pihole"] # Selecting the 'pihole' key
  pve_ip                  = var.pve_ip
  private_key_path        = "~/.ssh/id_rsa"
  ip_address              = var.ip_address
  gateway_ip              = var.gateway_ip
  nameserver              = "1.1.1.1"
  pm_user                 = var.pm_user
  pm_password             = var.pm_password
  pm_api_url              = var.pm_api_url
  ciuser                  = "pihole"
  ssh_keys                = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4o/s7abXCP8bN4csqJ89boo3AAOS7fbSoFB0OxjEwIVdUvwXijCnlYrqT5eBdft4yy3SY2RJ3pa+2JNbC6FFqGuEu7HudLiCY0qfoxVD6O6Ds3h5C4Wn3eaQ6tWqE+mn3jQs5Aj3n16/qB1oTr9Pw2+mhuTO1gCjop0U3K8vlQuWUQlQhlTYf977qEejfL7IwJHaNcJQIUUBgrR3b8VCe1EBa5C0CLutxAKRRpmv80EkkEKULUYdV9Klg3DXeZYNyBXBfPm8YZMJhtpnJ6xMTzzGlqjuoOPiqDqlw0SyhpplzaZLjKcG6urF7wgmvQdIpi5GKmdWundXKOETaC/1R davidmcgough@Davids-iMac.home
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbfXSyv6ugfAEBac79iqSIYI9BDyowe98RSlKlwLoPoImWefhKAzYEpk64TSqdItKK7td9Tbp6poPfiNvM3ZrBWU+pIWr2yGLvthF021R/1csQnSZjm6TNuIjwztaWfktZsiCwIK8bCAWy3ZUDDDvA0B93SswhqD7saR+WojRukGgIxc44wSGaw8Zp2h8CMh30ApozNCUG7pRfm/va7xm7WcJLYi3Fo1nR3BVqwyjPtMijb30QZ/Y9w9sH7UMW8XDJ/mBn0J4pECSCsiL57s/yr7MxVMXf+llxlf9Lh9+A3x0BTLYnWnZWe8oqmSNbZOYwsn1JlpF9wAThCuoe8YRPfGzby+kE4ZBB5ZfZvZeIW171pGMh1TVEzQhRSQA76Bdewt6n1vqhXiiEROnQX4iRjnd6y97pXFX1bwh++SZNZH9mAd/8Y92kzPg2wgk6ZJSrJ7O04Opa/h5Z5+a1LEB8F+HFTB+Jlu1w2hkWI8bIFcjepsM6BhIHat2cKIv3/oyKIKMx49YqG8T988WKj0vTZnaBAB3ZJiO50Ni4xkswUUwiPhI2ww5jbHZpAOvu4pNo1qLJAdDQxhPM5Uzea8oWxTgeeG/9WEy6NbNAJgn40CTzkJK9A7cnEjU5DbUY+1zlK3fRe+8xzPUCU757V5JdxX3sQgPi6umRdG1O2DoIgQ== root@pve
    EOF
}

module "plex_vm" {
  source                  = "./modules/vm"
  name                    = "plex-vm"
  node                    = "pve"
  template                = "debian-12-template"
  cores                   = 2
  memory                  = 2048
  sockets                 = 1
  disk_size               = "128G"
  cloud_init_filename     = "plex_cloud_init.yml"
  cloud_init_local_path   = "${path.module}/files/plex-cloud-init.cfg"
  cloud_init_tpl_filename = "${path.module}/plex-cloud-init.tpl"
  cloud_init_vars         = var.cloud_init_vars["plex"] # Selecting the 'pihole' key
  pve_ip                  = var.pve_ip
  private_key_path        = "~/.ssh/id_rsa"
  ip_address              = var.plex_ip_address
  gateway_ip              = var.gateway_ip
  nameserver              = "1.1.1.1"
  pm_user                 = var.pm_user
  pm_password             = var.pm_password
  pm_api_url              = var.pm_api_url
  ciuser                  = "plex"
  ssh_keys                = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4o/s7abXCP8bN4csqJ89boo3AAOS7fbSoFB0OxjEwIVdUvwXijCnlYrqT5eBdft4yy3SY2RJ3pa+2JNbC6FFqGuEu7HudLiCY0qfoxVD6O6Ds3h5C4Wn3eaQ6tWqE+mn3jQs5Aj3n16/qB1oTr9Pw2+mhuTO1gCjop0U3K8vlQuWUQlQhlTYf977qEejfL7IwJHaNcJQIUUBgrR3b8VCe1EBa5C0CLutxAKRRpmv80EkkEKULUYdV9Klg3DXeZYNyBXBfPm8YZMJhtpnJ6xMTzzGlqjuoOPiqDqlw0SyhpplzaZLjKcG6urF7wgmvQdIpi5GKmdWundXKOETaC/1R davidmcgough@Davids-iMac.home
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbfXSyv6ugfAEBac79iqSIYI9BDyowe98RSlKlwLoPoImWefhKAzYEpk64TSqdItKK7td9Tbp6poPfiNvM3ZrBWU+pIWr2yGLvthF021R/1csQnSZjm6TNuIjwztaWfktZsiCwIK8bCAWy3ZUDDDvA0B93SswhqD7saR+WojRukGgIxc44wSGaw8Zp2h8CMh30ApozNCUG7pRfm/va7xm7WcJLYi3Fo1nR3BVqwyjPtMijb30QZ/Y9w9sH7UMW8XDJ/mBn0J4pECSCsiL57s/yr7MxVMXf+llxlf9Lh9+A3x0BTLYnWnZWe8oqmSNbZOYwsn1JlpF9wAThCuoe8YRPfGzby+kE4ZBB5ZfZvZeIW171pGMh1TVEzQhRSQA76Bdewt6n1vqhXiiEROnQX4iRjnd6y97pXFX1bwh++SZNZH9mAd/8Y92kzPg2wgk6ZJSrJ7O04Opa/h5Z5+a1LEB8F+HFTB+Jlu1w2hkWI8bIFcjepsM6BhIHat2cKIv3/oyKIKMx49YqG8T988WKj0vTZnaBAB3ZJiO50Ni4xkswUUwiPhI2ww5jbHZpAOvu4pNo1qLJAdDQxhPM5Uzea8oWxTgeeG/9WEy6NbNAJgn40CTzkJK9A7cnEjU5DbUY+1zlK3fRe+8xzPUCU757V5JdxX3sQgPi6umRdG1O2DoIgQ== root@pve
    EOF
}
