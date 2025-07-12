#!/bin/bash
# Script to uninstall act on Linux/macOS

set -e

# Determine OS
OS=$(uname -s)
case "$OS" in
  Linux*)  PLATFORM=Linux ;;
  Darwin*) PLATFORM=macOS ;;
  *)       echo "Unsupported OS: $OS"; exit 1 ;;
esac

echo "Uninstalling act on $PLATFORM..."

# Remove act binary
if [ -f "/usr/local/bin/act" ]; then
  sudo rm -f /usr/local/bin/act
  echo "Removed act binary from /usr/local/bin/act"
else
  echo "act binary not found in /usr/local/bin/act"
fi

# Remove act configuration directory (if exists)
ACT_CONFIG_DIR="$HOME/.act"
if [ -d "$ACT_CONFIG_DIR" ]; then
  rm -rf "$ACT_CONFIG_DIR"
  echo "Removed act configuration directory: $ACT_CONFIG_DIR"
else
  echo "act configuration directory not found: $ACT_CONFIG_DIR"
fi

# Verify act is removed
if command -v act >/dev/null 2>&1; then
  echo "Warning: act is still accessible in PATH. You may need to remove it manually from $(which act)"
else
  echo "act successfully uninstalled"
fi