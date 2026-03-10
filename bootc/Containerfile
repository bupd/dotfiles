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
    base-devel \
    qemu-full \
    && pacman -S --clean --noconfirm

# k3s binary
# k3s binary (downloaded externally or via: curl -sfL -o k3s "https://github.com/k3s-io/k3s/releases/download/v1.34.5%2Bk3s1/k3s")
COPY k3s /usr/local/bin/k3s
RUN chmod +x /usr/local/bin/k3s && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/crictl && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/ctr

# k3s systemd service
COPY files/k3s.service /usr/lib/systemd/system/k3s.service

# ufw firewall - lockdown for public cloud
# Configure rules at build time; ufw enable requires iptables/kernel so
# we set ENABLED=yes and let systemd start it at boot
RUN ufw default deny incoming && \
    ufw default allow outgoing && \
    ufw allow ssh && \
    ufw allow in on tailscale0 && \
    ufw allow 41641/udp && \
    sed -i 's/^ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf

# ESP sync script - fixes bootc not updating EFI partition on Arch
COPY files/bootc-sync-esp.sh /usr/local/bin/bootc-sync-esp.sh
RUN chmod +x /usr/local/bin/bootc-sync-esp.sh

# Systemd service to sync ESP on every boot
COPY files/bootc-sync-esp.service /usr/lib/systemd/system/bootc-sync-esp.service

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

# yay (AUR helper)
RUN --mount=type=tmpfs,dst=/tmp \
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
    chown -R bupd:bupd /tmp/yay-bin && \
    runuser -u bupd -- bash -c "cd /tmp/yay-bin && makepkg --noconfirm" && \
    pacman -U --noconfirm /tmp/yay-bin/*.pkg.tar.zst

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

# Claude Code (native binary)
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    ln -sf ~/.local/bin/claude /usr/local/bin/claude

# Homebrew
RUN --mount=type=tmpfs,dst=/tmp \
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    /home/linuxbrew/.linuxbrew/bin/brew install lima && \
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
COPY files/sessionizer /var/home/bupd/sessionizer
RUN chmod +x /var/home/bupd/sessionizer && \
    mkdir -p /var/home/bupd/.local/bin && \
    ln -sf /var/home/bupd/sessionizer /var/home/bupd/.local/bin/sessionizer && \
    chown -R bupd:bupd /var/home/bupd/.local

# Zshrc (not managed by stow per .stow-local-ignore)
COPY files/zshrc /var/home/bupd/.zshrc
RUN chown bupd:bupd /var/home/bupd/.zshrc /var/home/bupd/sessionizer

LABEL containers.bootc 1
RUN bootc container lint
