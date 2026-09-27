#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname "$0")
SOURCE_DIR=$(CDPATH= cd "$SCRIPT_DIR" && pwd -P)
SOURCE_FILE="$SOURCE_DIR/kitty/kitty.conf"
CONFIG_DIR="${KITTY_CONFIG_DIRECTORY:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty}"
TARGET_FILE="$CONFIG_DIR/kitty.conf"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Missing Kitty configuration: $SOURCE_FILE" >&2
  exit 1
fi

if [ "$SOURCE_FILE" -ef "$TARGET_FILE" ]; then
  echo "Kitty config is already linked: $TARGET_FILE"
  exit 0
fi

if [ -e "$TARGET_FILE" ] || [ -L "$TARGET_FILE" ]; then
  echo "Refusing to overwrite existing Kitty config: $TARGET_FILE" >&2
  echo "Back it up or move it yourself, then run this script again." >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"
ln -s "$SOURCE_FILE" "$TARGET_FILE"
echo "Linked $TARGET_FILE -> $SOURCE_FILE"
echo "Restart Kitty or reload its configuration to apply changes."
