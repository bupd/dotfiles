# . "$HOME/.cargo/env"

# Make Homebrew-installed commands available to every zsh invocation.  Linux
# uses /home/linuxbrew; the other paths keep this dotfile portable to macOS.
typeset -gU path PATH
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
