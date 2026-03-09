#!/bin/bash
set -euo pipefail

# Build arch-bootc images and push to a container registry.
#
# Usage:
#   ./scripts/build.sh <registry> <username> <password>
#
# Example:
#   ./scripts/build.sh registry.goharbor.io/bupd/bootc robot_bupd+bootc Harbor12345

REGISTRY="${1:?Usage: $0 <registry> <username> <password>}"
USERNAME="${2:?Usage: $0 <registry> <username> <password>}"
PASSWORD="${3:?Usage: $0 <registry> <username> <password>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
REGISTRY_HOST="$(echo "$REGISTRY" | cut -d/ -f1)"

echo "## Logging into registry: $REGISTRY_HOST"
sudo podman login "$REGISTRY_HOST" -u "$USERNAME" -p "$PASSWORD"

echo ""
echo "## Building base image (this compiles bootc from source, ~20-40 min)"
sudo podman build --network=host -f "$REPO_DIR/Containerfile.base" -t arch-bootc:latest "$REPO_DIR"

echo ""
echo "## Tagging base image so Containerfile FROM resolves"
sudo podman tag arch-bootc:latest ghcr.io/bootcrew/arch-bootc:latest

echo ""
echo "## Building hetzner image"
sudo podman build --network=host -f "$REPO_DIR/Containerfile" -t "$REGISTRY:latest" "$REPO_DIR"

echo ""
echo "## Pushing to $REGISTRY:latest"
sudo podman push "$REGISTRY:latest"

echo ""
echo "## Done. Image pushed to $REGISTRY:latest"
