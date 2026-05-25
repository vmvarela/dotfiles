#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_CONFIG="$HOME/.config/opencode"

mkdir -p "$OPENCODE_CONFIG"

for file in opencode.json oh-my-opencode-slim.json tui.json; do
  target="$OPENCODE_CONFIG/$file"
  source="$DOTFILES_DIR/opencode/$file"

  if [ -L "$target" ]; then
    echo "Symlink already exists: $target"
  elif [ -f "$target" ]; then
    echo "Backing up $target to ${target}.bak"
    cp "$target" "${target}.bak"
    ln -sf "$source" "$target"
    echo "Linked: $target → $source"
  else
    ln -s "$source" "$target"
    echo "Linked: $target → $source"
  fi
done

echo "Done."
