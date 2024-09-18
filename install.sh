#!/bin/bash

# Variables
TARGET_DIR="/var/lib/vz/snippets"   # Replace with your target directory path
SOURCE_DIR="."

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

echo "Script completed."
