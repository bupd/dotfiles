#!/bin/bash
set -euo pipefail

ESP="/boot/efi"
BOOT="/boot"

# Ensure ESP is mounted
if ! mountpoint -q "$ESP"; then
    EFI_PART=$(blkid -t PARTLABEL="EFI System" -o device 2>/dev/null | head -1)
    if [ -z "$EFI_PART" ]; then
        EFI_PART=$(blkid -t TYPE="vfat" -o device 2>/dev/null | head -1)
    fi
    if [ -n "$EFI_PART" ]; then
        mount "$EFI_PART" "$ESP"
    else
        echo "bootc-sync-esp: no EFI partition found"
        exit 1
    fi
fi

# Install systemd-boot binary
mkdir -p "$ESP/EFI/BOOT" "$ESP/EFI/systemd"
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi "$ESP/EFI/BOOT/BOOTX64.EFI"
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi "$ESP/EFI/systemd/systemd-bootx64.efi"

# Find the active loader directory (bootc rotates between loader.0 and loader.1)
LOADER_DIR=$(readlink -f "$BOOT/loader" 2>/dev/null)
if [ ! -d "$LOADER_DIR/entries" ]; then
    for d in "$BOOT"/loader.0 "$BOOT"/loader.1; do
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

# Clean old kernels from ESP, then sync current ones
rm -rf "$ESP/ostree"
for OSTREE_DIR in "$BOOT"/ostree/default-*; do
    if [ -d "$OSTREE_DIR" ]; then
        DEST="$ESP/ostree/$(basename "$OSTREE_DIR")"
        mkdir -p "$DEST"
        cp "$OSTREE_DIR"/vmlinuz-* "$DEST/" 2>/dev/null || true
        cp "$OSTREE_DIR"/initramfs-* "$DEST/" 2>/dev/null || true
    fi
done

echo "bootc-sync-esp: ESP synced successfully"
