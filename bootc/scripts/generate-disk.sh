#!/bin/bash
set -euo pipefail

# Generate a bootable disk image from the container image and optionally
# push it to a registry using oras.
#
# Usage:
#   ./scripts/generate-disk.sh <registry> [username] [password]
#
# Example:
#   ./scripts/generate-disk.sh registry.goharbor.io/bupd/bootc robot_bupd+bootc Harbor12345

REGISTRY="${1:?Usage: $0 <registry> [username] [password]}"
USERNAME="${2:-}"
PASSWORD="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$REPO_DIR"
IMG="$OUTPUT_DIR/bootable.img"

echo "## Creating 20G disk image"
if [ ! -e "$IMG" ]; then
    fallocate -l 20G "$IMG"
fi

echo ""
echo "## Running bootc install to-disk"
sudo podman run \
    --rm --privileged --pid=host --network=host \
    -v /var/lib/containers:/var/lib/containers \
    -v /etc/containers:/etc/containers \
    -v /dev:/dev \
    -v "$OUTPUT_DIR:/data" \
    "$REGISTRY:latest" \
    bootc install to-disk \
    --composefs-backend \
    --via-loopback /data/bootable.img \
    --filesystem ext4 \
    --wipe \
    --bootloader systemd

echo ""
echo "## Disk image created: $IMG"
ls -lh "$IMG"

# Push to registry with oras if credentials provided
if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    ORAS_VERSION="1.2.2"
    REGISTRY_HOST="$(echo "$REGISTRY" | cut -d/ -f1)"

    if ! command -v oras &> /dev/null; then
        echo ""
        echo "## Installing oras CLI"
        curl -sLO "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
        tar -xzf "oras_${ORAS_VERSION}_linux_amd64.tar.gz" oras
        sudo mv oras /usr/local/bin/
        rm -f "oras_${ORAS_VERSION}_linux_amd64.tar.gz"
    fi

    echo ""
    echo "## Compressing disk image with zstd"
    zstd -f "$IMG" -o "$IMG.zst"
    ls -lh "$IMG.zst"

    echo ""
    echo "## Pushing disk image to $REGISTRY:disk-latest"
    oras login "$REGISTRY_HOST" -u "$USERNAME" -p "$PASSWORD"
    oras push "$REGISTRY:disk-latest" "$IMG.zst:application/octet-stream"

    echo ""
    echo "## Cleaning up local files"
    rm -f "$IMG" "$IMG.zst"

    echo "## Done. Disk image pushed to $REGISTRY:disk-latest"
else
    echo ""
    echo "## Skipping registry push (no credentials provided)"
    echo "## Disk image available at: $IMG"
fi
