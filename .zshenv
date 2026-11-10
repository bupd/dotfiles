# . "$HOME/.cargo/env"

# Make Homebrew-installed commands available to every zsh invocation.  Linux
# uses /home/linuxbrew; the other paths keep this dotfile portable to macOS.
typeset -gU path PATH

# Always resolve commands against the current PATH. Otherwise, a long-lived
# shell can keep using a system command cached before a Homebrew version was
# installed in the higher-priority prefix.
unsetopt HASH_CMDS

for brew_executable in \
  /home/linuxbrew/.linuxbrew/bin/brew \
  /opt/homebrew/bin/brew \
  /usr/local/bin/brew
do
  if [[ -x "$brew_executable" ]]; then
    eval "$("$brew_executable" shellenv)"
    break
  fi
done
unset brew_executable

# Herdr-managed panes: claude always runs with permissions bypassed.
# Herdr starts and resumes agents by typing `claude ...` into the pane's
# interactive shell (no per-agent launch-args config exists in herdr), so a
# shell function is the hook point. HERDR_ENV=1 is set only inside herdr panes.
if [[ "${HERDR_ENV:-}" == 1 ]]; then
  claude() {
    command claude --dangerously-skip-permissions "$@"
  }
fi
