#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
BACKUP_DIR="$STATE_DIR/backups"
WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"
DEFAULT_TARGET="/usr/bin/openrgb"

TARGET_BIN="$DEFAULT_TARGET"
if [ -f "$STATE_DIR/target_path" ]; then
    TARGET_BIN="$(cat "$STATE_DIR/target_path")"
fi

LATEST_BACKUP=""
if [ -d "$BACKUP_DIR" ]; then
    LATEST_BACKUP="$(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'openrgb.backup.*' -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1 {print $2}')"
fi

if [ -n "$LATEST_BACKUP" ]; then
    echo "Restoring original OpenRGB binary to: $TARGET_BIN"
    sudo install -m 755 "$LATEST_BACKUP" "$TARGET_BIN"
else
    echo "No backup binary was found."
    echo "Remove/reinstall your distro OpenRGB package if you need to restore it."
fi

echo "Removing build workspace and installer state."
sudo rm -rf "$WORKSPACE"
sudo rm -rf "$STATE_DIR"

echo "Done."
