#cloud-config

# Install necessary packages including Plex dependencies and NFS client
packages:
  - curl
  - apt-transport-https
  - ca-certificates
  - gnupg
  - nfs-common
  - vainfo
  - qemu-guest-agent

# Commands to be executed on first boot
runcmd:
  # Add Plex GPG key
  - curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor -o /usr/share/keyrings/plex.gpg
  # Add Plex repository
  - echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | tee /etc/apt/sources.list.d/plexmediaserver.list
  # Add non-free-firmware repo
  - echo "deb http://deb.debian.org/debian bookworm main contrib non-free-firmware" | tee -a /etc/apt/sources.list
  # Update apt and install Plex Media Server and firmware
  - apt update
  - apt install -y plexmediaserver firmware-misc-nonfree
  # Enable and start Plex service
  - systemctl enable plexmediaserver
  - systemctl start plexmediaserver
  # Create NFS mount point directory
  - mkdir -p /mnt/media
  # Mount all filesystems defined in /etc/fstab
  - mount -a
  # Start the qemu-guest-agent
  - systemctl start qemu-guest-agent

# NFS Configuration
mounts:
  # Example: Mount NFS share from 10.0.0.2 at /mnt/media
  - [ "10.0.0.2:/volume1/media", "/mnt/media", "nfs", "defaults", "0", "0" ]

# Set Plex configuration to run with necessary permissions
final_message: "Plex Media Server installation and NFS mount complete!"