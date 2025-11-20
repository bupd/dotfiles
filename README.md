
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

### **📸 My Keyboard Layout - Corne V3**

Screenshots of the current layout are included in this repo:
### layer 0
<img width="1478" height="458" alt="Screenshot_2025-11-20_14-44-47" src="https://github.com/user-attachments/assets/e6282088-d567-4b6c-bc2d-bbb513ff88c4" />

### layer 1
<img width="1420" height="449" alt="Screenshot_2025-11-20_14-47-42" src="https://github.com/user-attachments/assets/19887259-4d6e-4634-b35c-9df44a9a1a66" />

### layer 2
<img width="1417" height="461" alt="Screenshot_2025-11-20_14-47-55" src="https://github.com/user-attachments/assets/1e28ff5f-0bee-4aa3-9a86-335388798f19" />

### layer 3 - i dont use this..
<img width="1477" height="455" alt="Screenshot_2025-11-20_14-48-13" src="https://github.com/user-attachments/assets/4541f1b6-32c3-46b5-b58c-418268058c37" />



## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or issues, feel free to reach out by opening an issue on GitHub.

---
### Note:
The `check_dependencies.sh` script checks for the presence of required programs and reports any that are missing. If you need additional functionality or more sophisticated handling of package installation, you might need to extend the script or use a more complex package management solution.
