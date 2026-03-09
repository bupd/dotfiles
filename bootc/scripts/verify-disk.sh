#!/bin/bash
set -euo pipefail

# Verify a bootc disk is correctly set up before rebooting.
# Run this from Hetzner rescue mode.
#
# Usage:
#   ./verify-disk.sh [disk]
#
# Example:
#   ./verify-disk.sh /dev/sda

DISK="${1:-/dev/sda}"
ERRORS=0

check() {
    local desc="$1"
    local result="$2"
    if [ -n "$result" ]; then
        echo "[OK]   $desc"
    else
        echo "[FAIL] $desc"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "## Verifying bootc disk: $DISK"
echo ""

# Find partitions
EFI_PART=$(fdisk -l "$DISK" 2>/dev/null | grep "EFI System" | awk '{print $1}')
ROOT_PART=$(fdisk -l "$DISK" 2>/dev/null | grep "Linux root" | awk '{print $1}')

check "EFI partition found" "$EFI_PART"
check "Root partition found" "$ROOT_PART"

if [ -z "$ROOT_PART" ] || [ -z "$EFI_PART" ]; then
    echo ""
    echo "## Cannot continue without both partitions"
    exit 1
fi

# Mount
mount "$ROOT_PART" /mnt 2>/dev/null || true
mount "$EFI_PART" /mnt/boot/efi 2>/dev/null || true

echo ""
echo "## EFI Bootloader"
check "BOOTX64.EFI exists" "$(ls /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI 2>/dev/null)"

echo ""
echo "## Loader Config"
check "loader.conf exists" "$(ls /mnt/boot/efi/loader/loader.conf 2>/dev/null)"
check "ostree-1.conf exists" "$(ls /mnt/boot/efi/loader/entries/ostree-1.conf 2>/dev/null)"

if [ -f /mnt/boot/efi/loader/entries/ostree-1.conf ]; then
    echo ""
    echo "## Boot Entry"
    cat /mnt/boot/efi/loader/entries/ostree-1.conf
fi

echo ""
echo "## Kernel and Initramfs on ESP"
check "Kernel on ESP" "$(find /mnt/boot/efi -name 'vmlinuz-*' 2>/dev/null)"
check "Initramfs on ESP" "$(find /mnt/boot/efi -name 'initramfs-*' 2>/dev/null)"

echo ""
echo "## Root UUID"
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
ENTRY_UUID=$(grep -oP 'UUID=\K[^ ]+' /mnt/boot/efi/loader/entries/ostree-1.conf 2>/dev/null || true)
echo "   Disk:  $ROOT_UUID"
echo "   Entry: $ENTRY_UUID"
if [ "$ROOT_UUID" = "$ENTRY_UUID" ]; then
    echo "[OK]   UUIDs match"
else
    echo "[FAIL] UUIDs do NOT match"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "## Ostree Deployment"
DEPLOY=$(ls -d /mnt/ostree/deploy/default/deploy/*.0 2>/dev/null | head -1)
check "Deployment exists" "$DEPLOY"

if [ -n "$DEPLOY" ]; then
    echo ""
    echo "## SSH Access"
    check "sshd enabled" "$(ls $DEPLOY/etc/systemd/system/multi-user.target.wants/sshd.service 2>/dev/null)"
    check "authorized_keys exists" "$(ls $DEPLOY/var/home/*/. ssh/authorized_keys 2>/dev/null)"

    echo ""
    echo "## Network"
    check "networkd enabled" "$(find $DEPLOY/etc/systemd -name '*networkd.service' 2>/dev/null)"
fi

echo ""
echo "## Partition Size"
df -h "$ROOT_PART" | tail -1

# Cleanup
umount /mnt/boot/efi 2>/dev/null || true
umount /mnt 2>/dev/null || true

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "## ALL CHECKS PASSED - safe to reboot"
else
    echo "## $ERRORS CHECK(S) FAILED - fix before rebooting"
    exit 1
fi
