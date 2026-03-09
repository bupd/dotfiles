#!/bin/bash
set -euo pipefail

# Flash a bootable disk image to a Hetzner server from rescue mode.
# Run this script INSIDE the Hetzner rescue environment.
#
# Usage:
#   ./flash-disk.sh <registry> <username> <password> [disk]
#
# Example:
#   ./flash-disk.sh registry.goharbor.io/bupd/bootc robot_bupd+bootc Harbor12345 /dev/sda

REGISTRY="${1:?Usage: $0 <registry> <username> <password> [disk]}"
USERNAME="${2:?Usage: $0 <registry> <username> <password> [disk]}"
PASSWORD="${3:?Usage: $0 <registry> <username> <password> [disk]}"
DISK="${4:-/dev/sda}"

REGISTRY_HOST="$(echo "$REGISTRY" | cut -d/ -f1)"
ORAS_VERSION="1.2.2"

echo "## Target disk: $DISK"
lsblk "$DISK"
echo ""
read -p "This will ERASE $DISK. Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Install oras
if ! command -v oras &> /dev/null; then
    echo ""
    echo "## Installing oras"
    curl -sLO "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
    tar -xzf "oras_${ORAS_VERSION}_linux_amd64.tar.gz" oras
    chmod +x oras
    ORAS=./oras
    rm -f "oras_${ORAS_VERSION}_linux_amd64.tar.gz"
else
    ORAS=oras
fi

# Pull disk image
echo ""
echo "## Logging into registry"
$ORAS login "$REGISTRY_HOST" -u "$USERNAME" -p "$PASSWORD"

echo ""
echo "## Pulling disk image from $REGISTRY:disk-latest"
$ORAS pull "$REGISTRY:disk-latest"

# Decompress
echo ""
echo "## Decompressing"
apt-get update -qq && apt-get install -y -qq zstd > /dev/null 2>&1
zstd -d bootable.img.zst

# Write to disk
echo ""
echo "## Writing to $DISK"
dd if=bootable.img of="$DISK" bs=4M status=progress
sync

# Find the root partition (largest Linux partition)
echo ""
echo "## Resizing root partition to fill disk"
ROOT_PART=$(fdisk -l "$DISK" 2>/dev/null | grep "Linux root" | awk '{print $1}')
PART_NUM=$(echo "$ROOT_PART" | grep -o '[0-9]*$')

if [ -n "$PART_NUM" ]; then
    parted "$DISK" ---pretend-input-tty resizepart "$PART_NUM" 100% <<< "Fix"
    e2fsck -f "$ROOT_PART"
    resize2fs "$ROOT_PART"
    echo "## Partition $ROOT_PART resized"
else
    echo "## WARNING: Could not auto-detect root partition. Resize manually:"
    echo "##   fdisk -l $DISK"
    echo "##   parted $DISK resizepart <N> 100%"
    echo "##   e2fsck -f ${DISK}<N>"
    echo "##   resize2fs ${DISK}<N>"
fi

# Fix EFI bootloader (bootc doesn't sync ESP on Arch)
echo ""
echo "## Fixing EFI bootloader"
mount "$ROOT_PART" /mnt
EFI_PART=$(fdisk -l "$DISK" 2>/dev/null | grep "EFI System" | awk '{print $1}')

if [ -n "$EFI_PART" ]; then
    mount "$EFI_PART" /mnt/boot/efi
    ESP=/mnt/boot/efi

    # Find the latest ostree deployment
    DEPLOY=$(ls -dt /mnt/ostree/deploy/default/deploy/*.0 2>/dev/null | head -1)

    if [ -n "$DEPLOY" ]; then
        # Install systemd-boot EFI binary
        mkdir -p "$ESP/EFI/BOOT" "$ESP/EFI/systemd"
        cp "$DEPLOY/usr/lib/systemd/boot/efi/systemd-bootx64.efi" "$ESP/EFI/BOOT/BOOTX64.EFI"
        cp "$DEPLOY/usr/lib/systemd/boot/efi/systemd-bootx64.efi" "$ESP/EFI/systemd/systemd-bootx64.efi"

        # Find the active loader directory (follows the symlink)
        LOADER_DIR=$(readlink -f /mnt/boot/loader 2>/dev/null)
        if [ ! -d "$LOADER_DIR" ]; then
            # Fallback: try loader.0 then loader.1
            for d in /mnt/boot/loader.0 /mnt/boot/loader.1; do
                if [ -d "$d/entries" ]; then LOADER_DIR="$d"; break; fi
            done
        fi

        # Sync all loader entries to ESP
        mkdir -p "$ESP/loader/entries"
        rm -f "$ESP/loader/entries/"*.conf
        if [ -d "$LOADER_DIR/entries" ]; then
            cp "$LOADER_DIR/entries/"*.conf "$ESP/loader/entries/"
            sed -i 's|/boot/ostree/|/ostree/|g' "$ESP/loader/entries/"*.conf

            # Default to highest version entry
            DEFAULT_ENTRY=$(ls -1 "$ESP/loader/entries/" | sort -t- -k1 -rV | head -1)
            printf "default %s\ntimeout 5\n" "$DEFAULT_ENTRY" > "$ESP/loader/loader.conf"
        fi

        # Sync all kernels and initramfs to ESP
        rm -rf "$ESP/ostree"
        for OSTREE_BOOT_DIR in /mnt/boot/ostree/default-*; do
            if [ -d "$OSTREE_BOOT_DIR" ]; then
                DEST_DIR="$ESP/ostree/$(basename "$OSTREE_BOOT_DIR")"
                mkdir -p "$DEST_DIR"
                cp "$OSTREE_BOOT_DIR"/vmlinuz-* "$DEST_DIR/" 2>/dev/null || true
                cp "$OSTREE_BOOT_DIR"/initramfs-* "$DEST_DIR/" 2>/dev/null || true
            fi
        done

        echo "## EFI bootloader installed"
        echo "## Loader config:"
        cat "$ESP/loader/loader.conf"
        echo "## Entries:"
        ls "$ESP/loader/entries/"
    else
        echo "## WARNING: No ostree deployment found"
    fi

    umount /mnt/boot/efi
fi

umount /mnt
sync

# Cleanup
rm -f bootable.img bootable.img.zst

echo ""
echo "## Done. Disk is ready."
echo "## Next steps:"
echo "##   1. Disable rescue mode in Hetzner Cloud Console"
echo "##   2. Power Cycle the server"
echo "##   3. SSH in after 1-2 minutes"
