#cloud-config

packages:
  - nfs-common
  - qemu-guest-agent
  - gnupg

# Commands to be executed on first boot
runcmd:
  - install -m 0755 -d /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - chmod a+r /etc/apt/keyrings/docker.gpg
  - echo "deb [arch="amd64" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "bookworm" stable" | tee /etc/apt/so>
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  # Create NFS mount point directory
  - mkdir -p /mnt/docker
  # Mount all filesystems defined in /etc/fstab
  - mount -a
  # Add the user to the docker group
  - usermod -aG docker docker  
  - reboot

# NFS Configuration 
mounts:
  # Example: Mount NFS share from 10.0.0.2 at /mnt/media
  - [ "10.0.0.2:/volume1/docker", "/mnt/docker", "nfs", "defaults", "0", "0" ]

# Set Docker VM configuration
final_message: "Docker VM installation and NFS mount complete!"