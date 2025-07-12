#!/bin/bash
# Script to install act on Linux/macOS

set -e

# Check for required tools
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting."; exit 1; }

# Determine OS
OS=$(uname -s)
case "$OS" in
  Linux*)  PLATFORM=Linux ;;
  Darwin*) PLATFORM=macOS ;;
  *)       echo "Unsupported OS: $OS"; exit 1 ;;
esac

echo "Installing act for $PLATFORM..."

# Download and install act
ACT_VERSION="0.2.52"
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# Move act binary to /usr/local/bin
sudo mv ./bin/act /usr/local/bin/act

# Verify installation
act --version || { echo "act installation failed"; exit 1; }

echo "act installed successfully!"

# Ensure Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "Starting Docker..."
  case "$PLATFORM" in
    Linux)
      sudo systemctl start docker
      ;;
    macOS)
      open -a "Rancher Desktop"
      sleep 10 # Wait for Rancher Desktop to start
      ;;
  esac
fi

echo "act is ready to use. Run 'act --help' for more information."