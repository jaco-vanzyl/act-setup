#!/bin/bash

# cleanup-act.sh: Script to clean up act binary, configuration, and Docker resources

set -e

echo "Cleaning up act and related Docker resources..."

# Remove act binary
if [ -f /usr/local/bin/act ]; then
  sudo rm -f /usr/local/bin/act
  echo "Removed act binary from /usr/local/bin/act"
else
  echo "act binary not found in /usr/local/bin/act"
fi

# Remove act configuration directory
if [ -d ~/.act ]; then
  rm -rf ~/.act
  echo "Removed act configuration directory ~/.act"
else
  echo "act configuration directory ~/.act not found"
fi

# Check if docker is installed and running
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Skipping Docker cleanup."
  exit 0
fi

if ! docker info &> /dev/null; then
  echo "Docker daemon not running. Skipping Docker cleanup."
  exit 0
fi

# Stop and remove act-related containers
echo "Checking for act-related Docker containers..."
act_containers=$(docker ps -a --filter "name=act-" --format "{{.ID}}")
if [ -n "$act_containers" ]; then
  for container_id in $act_containers; do
    echo "Stopping container $container_id..."
    docker stop "$container_id" || true
    echo "Removing container $container_id..."
    docker rm "$container_id" || true
  done
else
  echo "No act-related containers found."
fi

# Remove all stopped containers (optional, includes non-act containers)
echo "Removing all stopped Docker containers..."
docker container prune -f || true

# Remove act-related images
echo "Checking for act-related Docker images..."
act_images=$(docker images --filter=reference='ghcr.io/catthehacker/ubuntu:act*' --format "{{.ID}}")
if [ -n "$act_images" ]; then
  for image_id in $act_images; do
    echo "Removing image $image_id..."
    docker rmi "$image_id" || true
  done
else
  echo "No act-related images found."
fi

# Remove unused images (optional, includes non-act images)
echo "Removing unused Docker images..."
docker image prune -f || true

# Remove unused volumes (optional)
echo "Removing unused Docker volumes..."
docker volume prune -f || true

echo "Cleanup completed successfully."