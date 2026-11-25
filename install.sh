#!/bin/sh
# install.sh — desktop-side installer for the agent-tools collection.
#
# Copies bins into ~/.bin and ~/.local/bin, systemd units into
# ~/.config/systemd/user, and the kitty-debug config (with @HOME@
# substituted). Idempotent: re-running overwrites the managed files.
# Env handlers under ~/.config/omp-debug/envs are left untouched.
set -eu
cd "$(dirname "$0")"

mkdir -p "$HOME/.bin" "$HOME/.local/bin" "$HOME/.config/systemd/user" \
         "$HOME/.config/kitty-debug" "$HOME/.config/omp-debug/envs"

# Desktop-side bins: session switching + the debug-channel receiver.
install -m 0755 bin/nodeshell bin/omp-debug-dispatch bin/omp-debug-kitty \
  bin/omp-debug-new-env "$HOME/.bin/"

# General-purpose utilities.
install -m 0755 bin/mdrecall bin/systemd-urun bin/git bin/cargo "$HOME/.local/bin/"

# Slices + the per-project agent session template.
install -m 0644 systemd/gg@.service systemd/development.slice \
  systemd/development-build.slice "$HOME/.config/systemd/user/"
systemctl --user daemon-reload

# Debug kitty config; @HOME@ -> the real home (kitty.conf does no expansion).
sed "s|@HOME@|$HOME|g" kitty-debug/kitty.conf > "$HOME/.config/kitty-debug/kitty.conf"
install -m 0644 kitty-debug/auth.py "$HOME/.config/kitty-debug/auth.py"

cat <<EOF

Desktop side done. Remaining steps:

  Agent user side (once):
    install -m 0755 bin/omp-debug-trigger ~/.local/bin/
    mkdir -p ~/.config/omp-debug
    echo "DESKTOP_HOME=$HOME" > ~/.config/omp-debug/config

  Per project (desktop side):
    omp-debug-new-env <env>                     # stamp a key handler
    systemctl --user enable --now gg@<env>      # optional: tmux agent session

  Day to day:
    omp-debug-kitty <env>   # debug kitty running nodeshell <env>
EOF
