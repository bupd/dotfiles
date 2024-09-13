
![Header](https://github.com/user-attachments/assets/22c7f4ca-db1c-4ada-8ede-5f2e252fe87e)
<h1 align="center"> Dotfiles</h1>

This repository contains my personal dotfiles managed using [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html). It includes configuration files for various programs and utilities that I use. The goal is to make it easy to manage and synchronize these files across different systems.

## Setup Instructions

### Check and Install Required Programs
To ensure that all necessary programs are installed on your system, you can use the following script.

```bash
./check_dependencies.sh
```

Ensure you have GNU Stow installed on your system. You can typically install it using your package manager:

- On Debian-based systems (Ubuntu, etc.): `sudo apt install stow`
- On Red Hat-based systems (Fedora, CentOS, etc.): `sudo dnf install stow`
- On macOS: `brew install stow`
- On ArchBTW: `sudo pacman -S stow`

### Using Stow

1. **Clone this repository**:

    ```bash
    git clone https://github.com/bupd/dotfiles.git
    cd dotfiles
    ```

2. **Adopt the files**:

    To copy the files into their proper locations:

    ```bash
    stow --adopt .
    ```

    Alternatively,
    ```bash
    stow . --adopt
    ```

### Included Files

This repository contains the following configuration files and scripts:

- `.config` - Configuration directory
- `i3` - i3 window manager configuration
- `i3status` - i3status configuration
- `nvim` - Neovim configuration
- `pactl.sh` - Script for managing PulseAudio
- `pactlVmic.sh` - Script for managing PulseAudio virtual microphone
- `picom.conf` - Picom (compositor) configuration
- `powerkill.sh` - Script to handle power-related actions
- `scripts` - Directory containing various utility scripts
- `sessionizer` - Script for TMUX session management
- `.xinitrc` - X11 initialization script
- `.zshrc` - Zsh shell configuration





## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or issues, feel free to reach out by opening an issue on GitHub.

---
### Note:
The `check_dependencies.sh` script checks for the presence of required programs and reports any that are missing. If you need additional functionality or more sophisticated handling of package installation, you might need to extend the script or use a more complex package management solution.
