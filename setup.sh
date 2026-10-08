#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_CONFIG="$HOME/.config/opencode"

mkdir -p "$OPENCODE_CONFIG"

for entry in opencode.json cli.json sounds opencode-quota; do
  target="$OPENCODE_CONFIG/$entry"
  source="$DOTFILES_DIR/opencode/$entry"

  if [ -L "$target" ]; then
    echo "Symlink already exists: $target"
  elif [ -e "$target" ]; then
    echo "Backing up $target to ${target}.bak"
    mv "$target" "${target}.bak"
    ln -s "$source" "$target"
    echo "Linked: $target → $source"
  else
    ln -s "$source" "$target"
    echo "Linked: $target → $source"
  fi
done

echo "Done."
