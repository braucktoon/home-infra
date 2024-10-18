#!/bin/bash

# Variables
# Directory where the repo will be cloned
CLONE_DIR="home-infra"
# GitHub repository URL
REPO_URL="https://github.com/braucktoon/home-infra.git"
# Call additional scripts with error checking
SCRIPT1="$CLONE_DIR/cloud-init/debian/debian-12-cloudinit.sh"

# Function to handle errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check if git is installed, if not, install it
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing git..."
    apt-get update || error_exit "Failed to update package list. Exiting..."
    apt-get install -y git || error_exit "Failed to install git. Exiting..."
else
    echo "Git is already installed."
fi

# Clone the repository
echo "Cloning repository from $REPO_URL..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR" || error_exit "Failed to clone repository. Exiting..."

# Check if the clone was successful
if [ -d "$CLONE_DIR" ]; then
    echo "Repository successfully cloned into $CLONE_DIR."
else
    error_exit "Repository not cloned. Exiting..."
fi

if [ -f "$SCRIPT1" ]; then
  echo "Calling script1.sh..."
  bash "$SCRIPT1"
  if [ $? -ne 0 ]; then
    echo "Error: script1.sh failed." >&2
    exit 1
  fi

else
  echo "Script not found. Please check the paths."
  exit 1
fi

# Run the haos-vm.sh script and check if it completes successfully
echo "Running haos-vm.sh from GitHub..."
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/vm/haos-vm.sh)"
if [ $? -ne 0 ]; then
  echo "Error: haos-vm.sh failed to run." >&2
  exit 1
else
  echo "haos-vm.sh completed successfully."
fi

echo "All tasks completed successfully."

