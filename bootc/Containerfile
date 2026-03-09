FROM ghcr.io/bootcrew/arch-bootc:latest

# Core server + dev packages
RUN --mount=type=tmpfs,dst=/tmp --mount=type=cache,dst=/usr/lib/sysimage/cache/pacman \
    pacman -Syu --noconfirm \
    openssh \
    sudo \
    vim \
    neovim \
    htop \
    btop \
    curl \
    wget \
    git \
    tmux \
    zsh \
    stow \
    fzf \
    ripgrep \
    fd \
    jq \
    go \
    gcc \
    make \
    unzip \
    gnupg \
    rsync \
    net-tools \
    iproute2 \
    traceroute \
    tailscale \
    qemu-guest-agent \
    ufw \
    grub \
    less \
    lazygit \
    podman-docker \
    podman-compose \
    kubectl \
    helm \
    k9s \
    yq \
    gopls \
    python \
    lua \
    luarocks \
    tree \
    lsof \
    man-db \
    && pacman -S --clean --noconfirm

# k3s binary
RUN K3S_VERSION=$(curl -sfL https://update.k3s.io/v1-release/channels/stable | jq -r '.data[0].latest') && \
    curl -sfL -o /usr/local/bin/k3s "https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s" && \
    chmod +x /usr/local/bin/k3s && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/crictl && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/ctr

# k3s systemd service
COPY --chmod=0644 <<'K3SUNIT' /usr/lib/systemd/system/k3s.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/k3s
ExecStartPre=/bin/sh -xc '! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service 2>/dev/null'
ExecStart=/usr/local/bin/k3s server
KillMode=process
Delegate=yes
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
K3SUNIT

# ufw firewall - lockdown for public cloud
RUN ufw default deny incoming && \
    ufw default allow outgoing && \
    ufw allow ssh && \
    ufw allow in on tailscale0 && \
    ufw allow 41641/udp && \
    ufw enable

# ESP sync script - fixes bootc not updating EFI partition on Arch
COPY --chmod=0755 <<'ESPFIX' /usr/local/bin/bootc-sync-esp.sh
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
ESPFIX

# Systemd service to sync ESP on every boot
COPY --chmod=0644 <<'UNIT' /usr/lib/systemd/system/bootc-sync-esp.service
[Unit]
Description=Sync bootc bootloader to EFI System Partition
DefaultDependencies=no
After=local-fs.target
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/bootc-sync-esp.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
UNIT

# Enable services
RUN systemctl enable sshd systemd-networkd systemd-resolved systemd-timesyncd tailscaled qemu-guest-agent serial-getty@ttyS0 bootc-sync-esp ufw k3s

# Timezone and locale
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network - DHCP on all ethernet interfaces (Hetzner Cloud)
RUN printf '[Match]\nType=ether\n\n[Network]\nDHCP=yes\nIPv6AcceptRA=yes\n\n[DHCPv4]\nUseDNS=yes\nUseNTP=yes\n' \
    > /usr/lib/systemd/network/20-ethernet.network

# Create user bupd with zsh
RUN useradd -m -G wheel -s /bin/zsh bupd && \
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# SSH config - key-based auth only
RUN mkdir -p /etc/ssh/sshd_config.d && \
    printf 'PermitRootLogin no\nPasswordAuthentication no\nPubkeyAuthentication yes\nAllowUsers bupd\n' \
    > /etc/ssh/sshd_config.d/10-hetzner.conf

# SSH authorized key for bupd
RUN mkdir -p /var/home/bupd/.ssh && chmod 700 /var/home/bupd/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgOxVumFr4SNyhIXl5dfCYlZBON3EApcxrcBq3wvR/3BuY1jqJtmlppNffht6qmbAVOnJvJCxfQuWc5ju8O9/GSorVq+1qFmiIjIJv8hnqxed2BbHqko7jB1fgG3aDFUN6UhySYF2fBEcKWbAZEntOEuWo/ZrJyM2a/ktVd6aZrKghZ8HpN+PnX73ubYSTCrNUiAnDOssFJs6hpuPbAGUcTmG9E48kGKmbzBCRnxDbWotafwLj9PmTRT3e1TABRljd+UYnVkAmqXWFqEV12rMOZgPz/Lw6oKzrHdCUs1a325zpaek8Ffe3pzZtHIYERrft4pdTtnnaZQwoSxVkWaLvnBeuB1xqmDsGlF1xWNmMBbOanWZcwLIWkaVUaS/dvOju9xWGmOhhMjeUoMQodlPF+epwS5Iop2atm/uWzsGJBeZCGC/Yvcm8qgXo8EOWhHWjqopzVVr892QXrtwvOf6O+/7iVgYTtvoeNh9dAbiYbqFaJvLjIMOQ7UfzHtaO9Gc=" \
    > /var/home/bupd/.ssh/authorized_keys && \
    chmod 600 /var/home/bupd/.ssh/authorized_keys && \
    chown -R bupd:bupd /var/home/bupd/.ssh && \
    mkdir -p /var/home/bupd/code && chown bupd:bupd /var/home/bupd/code

# Bun
RUN BUN_INSTALL=/usr/local/share/bun curl -fsSL https://bun.sh/install | bash && \
    ln -sf /usr/local/share/bun/bin/bun /usr/local/bin/bun && \
    ln -sf /usr/local/share/bun/bin/bunx /usr/local/bin/bunx

# Homebrew
RUN --mount=type=tmpfs,dst=/tmp \
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    /home/linuxbrew/.linuxbrew/bin/brew install claude-code && \
    chown -R bupd:bupd /home/linuxbrew 2>/dev/null || true

# Git config
RUN printf '[user]\n\tname = bupd\n\temail = bupdprasanth@gmail.com\n\tsigningkey = EFD822952819E418\n[core]\n\teditor = nvim\n[pull]\n\trebase = true\n[merge]\n\ttool = nvimdiff\n[diff]\n\ttool = nvimdiff\n\tcolorMoved = default\n[rerere]\n\tenabled = true\n\tautoUpdate = true\n[commit]\n\tgpgsign = true\n[tag]\n\tgpgsign = true\n[gpg]\n\tprogram = gpg\n' \
    > /var/home/bupd/.gitconfig && \
    chown bupd:bupd /var/home/bupd/.gitconfig

# Clone and stow dotfiles
RUN git clone https://github.com/bupd/dotfiles.git /var/home/bupd/dotfiles && \
    cd /var/home/bupd/dotfiles && \
    stow -d /var/home/bupd/dotfiles -t /var/home/bupd . && \
    chown -R bupd:bupd /var/home/bupd

# Server-specific sessionizer (overrides dotfiles version with correct paths)
COPY --chown=bupd:bupd <<'SESSIONIZER' /var/home/bupd/sessionizer
#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/code/ ~/ -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
SESSIONIZER
RUN chmod +x /var/home/bupd/sessionizer && \
    mkdir -p /var/home/bupd/.local/bin && \
    ln -sf /var/home/bupd/sessionizer /var/home/bupd/.local/bin/sessionizer && \
    chown -R bupd:bupd /var/home/bupd/.local

# Zshrc (not managed by stow per .stow-local-ignore)
COPY --chown=bupd:bupd <<'ZSHRC' /var/home/bupd/.zshrc
# Include sbin paths
export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char
bindkey '\b' backward-delete-char
bindkey '\C-h' backward-kill-word

# History
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias l='ls -al'
alias :q='exit'
alias ta='tmux a'
alias t='tmux'
alias c='clear'
alias gs='git status'
alias gfp='git fetch && git pull'
alias lz='lazygit'
alias d='podman'
alias dc='podman compose'

# Editor
export EDITOR='nvim'

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="/usr/lib/go/bin:/usr/local/go/bin:$GOPATH/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:/usr/local/share/bun/bin:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)"

# GPG tty for signing
export GPG_TTY=$(tty)

# Colored man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# fzf
eval "$(fzf --zsh)"
ZSHRC

LABEL containers.bootc 1
RUN bootc container lint
