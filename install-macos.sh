#!/bin/sh
set -eu

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
SCRIPT_DIR=$(dirname "$0")
SOURCE_DIR=$(CDPATH= cd "$SCRIPT_DIR" && pwd -P)

if [ ! -f "$SOURCE_DIR/init.lua" ] || [ ! -d "$SOURCE_DIR/lua/config" ]; then
  echo "This does not look like a Neovim config directory: $SOURCE_DIR" >&2
  exit 1
fi

if [ -e "$CONFIG_DIR" ] || [ -L "$CONFIG_DIR" ]; then
  if [ -L "$CONFIG_DIR" ]; then
    CURRENT_TARGET=$(readlink "$CONFIG_DIR")
    case "$CURRENT_TARGET" in
      /*) RESOLVED_TARGET=$(CDPATH= cd "$CURRENT_TARGET" 2>/dev/null && pwd -P || true) ;;
      *)
        RESOLVED_TARGET=$(
          CDPATH= cd "$(dirname "$CONFIG_DIR")" 2>/dev/null &&
            CDPATH= cd "$CURRENT_TARGET" 2>/dev/null &&
            pwd -P
        ) || RESOLVED_TARGET=""
        ;;
    esac

    if [ "$RESOLVED_TARGET" = "$SOURCE_DIR" ]; then
      echo "Neovim config is already linked:"
      echo "$CONFIG_DIR -> $SOURCE_DIR"
      exit 0
    fi
  fi

  echo "Refusing to overwrite existing Neovim config: $CONFIG_DIR" >&2
  echo "Back it up or move it yourself, then run this script again." >&2
  exit 1
fi

mkdir -p "$(dirname "$CONFIG_DIR")"
if ! ln -s "$SOURCE_DIR" "$CONFIG_DIR"; then
  echo "Could not create symlink. Another config may have appeared at: $CONFIG_DIR" >&2
  exit 1
fi

echo "Linked $SOURCE_DIR -> $CONFIG_DIR"
echo "Open Neovim with: nvim"
