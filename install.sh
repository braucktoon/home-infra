#!/bin/bash

# Variables
# Directory where the repo will be cloned
CLONE_DIR="home-infra"
TARGET_DIR="/var/lib/vz/snippets"   # Replace with your target directory path
SOURCE_DIR="$CLONE_DIR/cloud-init/apps"
# GitHub repository URL
REPO_URL="https://github.com/braucktoon/home-infra.git"
# Call additional scripts with error checking
SCRIPT1="$CLONE_DIR/cloud-init/debian/debian-12-cloudinit.sh"
SCRIPT2="$CLONE_DIR/cloud-init/debian/debian-12-cloudinit+docker.sh"

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

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory does not exist. Creating $TARGET_DIR..."
  mkdir -p "$TARGET_DIR"
else
  echo "Directory $TARGET_DIR already exists."
fi

# Check if there are any .yaml files and copy them
if ls "$SOURCE_DIR"/*.yaml 1> /dev/null 2>&1; then
  echo "Copying .yaml files to $TARGET_DIR..."
  cp "$SOURCE_DIR"/*.yaml "$TARGET_DIR"
  echo "Files copied successfully."
else
  echo "No .yaml files found in $SOURCE_DIR."
fi

if [ -f "$SCRIPT1" ] && [ -f "$SCRIPT2" ]; then
  echo "Calling script1.sh..."
  bash "$SCRIPT1"
  if [ $? -ne 0 ]; then
    echo "Error: script1.sh failed." >&2
    exit 1
  fi

  echo "Calling script2.sh..."
  bash "$SCRIPT2"
  if [ $? -ne 0 ]; then
    echo "Error: script2.sh failed." >&2
    exit 1
  fi

else
  echo "One or more scripts not found. Please check the paths."
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

