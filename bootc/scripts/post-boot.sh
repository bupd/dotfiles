#!/bin/bash
set -euo pipefail

# Post-boot setup script for a freshly flashed bootc Arch Linux system.
# Run this after the first successful boot.
#
# Usage:
#   ./post-boot.sh

echo "## Verifying system"
echo ""

echo "OS:"
cat /etc/os-release | grep PRETTY_NAME

echo ""
echo "Bootc status:"
bootc status 2>/dev/null || echo "bootc not available (expected if not in PATH)"

echo ""
echo "Services:"
for svc in sshd systemd-networkd systemd-resolved systemd-timesyncd tailscaled; do
    status=$(systemctl is-active "$svc" 2>/dev/null || echo "inactive")
    echo "  $svc: $status"
done

echo ""
echo "Network:"
ip -4 addr show scope global | grep inet

echo ""
echo "Disk:"
df -h / | tail -1

# Tailscale
echo ""
echo "## Tailscale"
if systemctl is-active tailscaled > /dev/null 2>&1; then
    if tailscale status > /dev/null 2>&1; then
        echo "Tailscale is connected"
        tailscale status | head -5
    else
        echo "Tailscale needs authentication. Run:"
        echo "  sudo tailscale up"
    fi
else
    echo "Tailscale is not running"
fi

# Hostname
echo ""
echo "## Hostname"
echo "Current: $(hostname)"
echo "To change: sudo hostnamectl set-hostname <new-name>"

# k3s
echo ""
echo "## k3s"
if command -v k3s &> /dev/null; then
    echo "k3s is installed"
    sudo k3s kubectl get nodes 2>/dev/null || echo "k3s is not running"
else
    echo "k3s is not installed. To install:"
    echo "  curl -sfL https://get.k3s.io | sh -"
fi

# GPG
echo ""
echo "## GPG"
if gpg --list-secret-keys 2>/dev/null | grep -q "sec"; then
    echo "GPG keys found"
else
    echo "No GPG secret keys. Import your key:"
    echo "  gpg --import your-private-key.asc"
fi

echo ""
echo "## Done"
