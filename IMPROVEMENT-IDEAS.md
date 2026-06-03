# Dotfiles Improvement Ideas

Audit of the dotfiles repository for bugs, stale configuration, and quality improvements.

---

## 1. Bugs

### `sessionizer` references non-existent paths

The `find` command on line 6 searches `~/s/code/Work/`, `~/s/code/8gears`, `~/s/code/`, etc.
The actual directory structure is `~/code/` (no `s/` prefix). Every path in the `find` invocation needs updating.

**File:** `sessionizer:6`

### `powerkill.sh` is empty

The file exists (and is listed in README) but contains no code at all.

**File:** `powerkill.sh`

### `scripts/load-scripts` is unimplemented

Has a shebang and a comment ("load all the scripts in '.' to the /usr/bin/ folder") but no actual logic.

**File:** `scripts/load-scripts`

### `.xinitrc` still has default twm/xclock config

Lines 51-55 launch `twm`, `xclock`, and `xterm` -- the stock Xorg defaults. It should launch i3 instead (e.g., `exec i3`). The cursor settings on lines 57-58 are also unreachable since `exec xterm` replaces the shell.

**File:** `.xinitrc:51-58`

### `nightshift.service` hardcodes a Homebrew Cellar version path

`ExecStart` points to `/var/home/linuxbrew/.linuxbrew/Cellar/nightshift/0.3.4/bin/nightshift`. This breaks on every nightshift upgrade because the version directory changes. Should use the symlinked path: `/var/home/linuxbrew/.linuxbrew/bin/nightshift`.

**File:** `.config/systemd/user/nightshift.service:7`

### `scripts/rm-harbor-clean.sh` is mislabeled

Filename suggests Harbor cleanup but the script actually deletes `node_modules` directories recursively -- identical in purpose to `rm-node_modules.sh`.

**File:** `scripts/rm-harbor-clean.sh`

### `scripts/airdopes` defines `DEVICE` variable but hardcodes MAC everywhere

Line 4 sets `DEVICE="80:EF:A9:DF:79:96"` but every subsequent `bluetoothctl` call and every `expect` string uses the literal MAC address instead of `$DEVICE`. The variable is effectively unused.

**File:** `scripts/airdopes:4-54`

### `scripts/images.sh` uses `docker` instead of `podman`

The system uses podman (containers config is present in `.config/containers/`), but this script calls `docker pull`, `docker tag`, and `docker push` directly.

**File:** `scripts/images.sh:17-24`

### `scripts/cputemp` uses polybar `%{F#...}` format strings

The color escape sequences (`%%{F#ed0b0b}`, `%{F-}`) are polybar-specific, but the system uses i3status (no polybar config exists). These escapes render as literal garbage in i3status or plain terminal output.

**File:** `scripts/cputemp:17-35`

---

## 2. Maintenance

### `check_dependencies.sh` lists stale dependencies and misses current ones

- Lists `alacritty`, `asdf`, `microsoft-edge-stable`, `ng` -- none appear used in current configs.
- Missing: `kitty`, `btop`, `podman`, `sensors`, `mediainfo`, `nvchecker`, `bluetoothctl`, `expect`, `bc`.

**File:** `check_dependencies.sh:4-24`

### `README.md` is outdated

- Lists `alacritty` and `.zshrc` but not `kitty`, `btop`, `cmux`, `.agents`, `nightshift`, `xremap`, `lazygit`, `yt-dlp`, `ytdl-sub`, `dunst`, or `yay`.
- "Included Files" section doesn't reflect the actual repo contents.
- No mention of the cmux tmux framework in `.config/tmux/`.

**File:** `README.md:48-60`

### `.zshenv` linuxbrew check may not apply on Arch/ostree

The file checks for `/home/linuxbrew/.linuxbrew/bin/brew` but the system root is `/var/home/` (Fedora Atomic / ostree). The path `/home/linuxbrew/` would need to be `/var/home/linuxbrew/` on this system, or the brew installation may no longer be relevant.

**File:** `.zshenv:2`

### `tmux.conf` has stale commented-out bindings

Lines 10, 30-31 contain commented-out alternative prefix and window-switching bindings. Minor clutter.

**File:** `.config/tmux/tmux.conf:10,30-31`

### `.config/git/ignore` is minimal

Only ignores `.claude/settings.local.json`. Could benefit from common ignores: `.DS_Store`, `*.swp`, `*.swo`, `*~`, `.env`, `__pycache__/`, `.direnv/`, etc.

**File:** `.gitignore` (repo-level) and `.config/git/ignore` (note: git/ignore has only one entry)

---

## 3. Quality

### Scripts lack `set -euo pipefail` and proper quoting

Most shell scripts (e.g., `sessionizer`, `images.sh`, `airdopes`, `cputemp`, `pactl.sh`) do not use `set -e` or `set -euo pipefail`, so failures pass silently. Several also have unquoted variables that will break on paths with spaces:

- `sessionizer:17` -- `$selected_name` and `$selected` unquoted in tmux calls
- `images.sh:17` -- `$image` unquoted in docker commands
- `.xinitrc:10` -- `$sysresources` unquoted

### `scripts/batch-delete.sh` not audited

May warrant review depending on what it batch-deletes -- could be destructive if run from the wrong directory.

### No shellcheck CI

Adding a GitHub Actions workflow to run `shellcheck` on all `.sh` files and shebanged scripts would catch many of the above issues automatically.

---

## Summary

| Category    | Count |
|-------------|-------|
| Bugs        | 9     |
| Maintenance | 5     |
| Quality     | 3     |

Most impactful quick wins:
1. Fix `sessionizer` paths (currently completely broken)
2. Fix `nightshift.service` to use the symlinked brew path
3. Replace `.xinitrc` default session with i3
4. Update `check_dependencies.sh` to reflect actual tooling
