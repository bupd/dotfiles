
![Header](https://github.com/user-attachments/assets/22c7f4ca-db1c-4ada-8ede-5f2e252fe87e)
<h1 align="center"> Dotfiles</h1>

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html). Includes configs for i3, neovim, tmux, zsh, kitty, and more. Also contains bootc image definitions for running Arch Linux on Hetzner Cloud.

## Quick Start

```bash
git clone https://github.com/bupd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./check_dependencies.sh
stow --adopt .
```

## Structure

```
dotfiles/
  .config/
    nvim/          # Neovim (NvChad) config
    tmux/          # Tmux config (prefix: Ctrl-j, vim-tmux-navigator)
    i3/            # i3 window manager
    i3status/      # i3 status bar
    kitty/         # Kitty terminal
    lazygit/       # Lazygit config
    xremap/        # Key remapping
    yt-dlp/        # yt-dlp config
  bootc/           # Arch Linux bootc image for Hetzner Cloud (not stowed)
    Containerfile        # Custom image (packages, users, dotfiles)
    Containerfile.base   # bootcrew/arch-bootc base image
    scripts/             # Build, flash, verify, post-boot scripts
  keyboard/        # Corne V3 keyboard layout
  scripts/         # Utility scripts
  sessionizer      # Tmux session picker (Ctrl-f in tmux)
  .p10k.zsh        # Powerlevel10k theme config
  .zshenv          # Zsh environment
  .zshrc           # Zsh config (zinit, p10k, fzf-tab) - not stowed
  .xinitrc         # X11 init
```

## Bootc (Hetzner Server)

The `bootc/` directory contains everything needed to build and deploy an immutable Arch Linux image to a Hetzner Cloud VPS using [bootc](https://github.com/bootc-dev/bootc).

```bash
cd ~/dotfiles/bootc

# Build and push image
./scripts/build.sh <registry> <username> <password>

# Generate bootable disk image and push via oras
./scripts/generate-disk.sh <registry> <username> <password>

# Flash from Hetzner rescue mode
./scripts/flash-disk.sh <registry> <username> <password>

# Verify before rebooting
./scripts/verify-disk.sh

# Update the running server
sudo bootc upgrade && sudo reboot
```

See [bupd/arch-bootc-hetzner](https://github.com/bupd/arch-bootc-hetzner) for full documentation.

## What's Included

| Tool | Config |
|---|---|
| Neovim | NvChad + custom plugins (LSP, DAP, telescope, treesitter) |
| Tmux | tpm, vim-navigator, resurrect, sessionizer |
| Zsh | zinit, powerlevel10k, fzf-tab, syntax-highlighting |
| i3 | Window manager with custom keybindings |
| Kitty | Terminal emulator |
| Lazygit | Git TUI |

## Keyboard - Corne V3

### Layer 0
<img width="1478" height="458" alt="Screenshot_2025-11-20_14-44-47" src="https://github.com/user-attachments/assets/e6282088-d567-4b6c-bc2d-bbb513ff88c4" />

### Layer 1
<img width="1420" height="449" alt="Screenshot_2025-11-20_14-47-42" src="https://github.com/user-attachments/assets/19887259-4d6e-4634-b35c-9df44a9a1a66" />

### Layer 2
<img width="1417" height="461" alt="Screenshot_2025-11-20_14-47-55" src="https://github.com/user-attachments/assets/1e28ff5f-0bee-4aa3-9a86-335388798f19" />

## License

MIT. See [LICENSE](LICENSE) for details.
