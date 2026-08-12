#!/usr/bin/env bash
# One-time host setup: stop builds from hard-locking the laptop (no swap + no OOM
# intervention = kernel thrashes until you force-reboot).
#
# Three parts:
#   1. 8GiB swapfile on /var (btrfs, NOCOW) — absorbs memory spikes.
#   2. systemd-oomd enabled — proactively kills the worst offender under sustained
#      memory pressure, before the whole system grinds to a halt.
#   3. MemoryHigh=85% / MemoryMax=92% on the user session slice — caps everything
#      *you* run (builds, browser, terminal) at 85% of RAM, reserving headroom for
#      system.slice and the kernel. Matches: "reserve 15% for system, never exceed
#      85% for other applications."
#
# Idempotent-ish: safe to re-run, but will skip the swapfile step if one already exists.
#
# Run with: sudo bash scripts/setup-ram-safety.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

SWAP_SUBVOL=/var/swap
SWAP_FILE="$SWAP_SUBVOL/swapfile"
SWAP_SIZE=8G

echo "==> [1/3] swapfile"
if swapon --show=NAME --noheadings | grep -q "^${SWAP_FILE}\$"; then
  echo "    already active, skipping"
elif [[ -f "$SWAP_FILE" ]]; then
  echo "    file exists but not active, enabling"
  swapon "$SWAP_FILE"
else
  btrfs subvolume create "$SWAP_SUBVOL"
  # btrfs-progs >=5.16 helper: handles NOCOW + no-compression + size + mkswap in one go
  btrfs filesystem mkswapfile --size "$SWAP_SIZE" "$SWAP_FILE"
  swapon "$SWAP_FILE"
  if ! grep -q "^${SWAP_FILE} " /etc/fstab 2>/dev/null; then
    echo "${SWAP_FILE} none swap defaults 0 0" >> /etc/fstab
  fi
  echo "    created ${SWAP_SIZE} swapfile at ${SWAP_FILE}, persisted in /etc/fstab"
fi

echo "==> [2/3] systemd-oomd"
mkdir -p /etc/systemd/oomd.conf.d
cat > /etc/systemd/oomd.conf.d/10-swap-limit.conf <<'EOF'
# Kill the worst offender before swap fills and the system starts thrashing.
[OOM]
SwapUsedLimit=90%
EOF
systemctl enable --now systemd-oomd.socket
echo "    systemd-oomd enabled"

echo "==> [3/3] user session memory cap (85% soft / 92% hard)"
mkdir -p /etc/systemd/system/user-.slice.d
cat > /etc/systemd/system/user-.slice.d/10-resource-limits.conf <<'EOF'
[Slice]
# Soft cap: kernel reclaims/throttles aggressively past this, rather than letting
# the session eat everything. Leaves >=15% of physical RAM for system.slice/kernel.
MemoryHigh=85%
# Hard backstop: cgroup-local OOM kill triggers inside the user session if this is
# hit, instead of a whole-system OOM stall.
MemoryMax=92%
# Let systemd-oomd proactively kill the biggest offender under sustained pressure
# within this slice (e.g. a runaway build) rather than the whole desktop hanging.
ManagedOOMMemoryPressure=kill
ManagedOOMMemoryPressureLimit=50%
EOF
systemctl daemon-reload
echo "    applied to user-.slice (all user sessions)"

echo
echo "Done. Current state:"
swapon --show
systemctl show user-$(logname 2>/dev/null || echo 1000).slice -p MemoryHigh -p MemoryMax 2>/dev/null
systemctl is-active systemd-oomd.service
