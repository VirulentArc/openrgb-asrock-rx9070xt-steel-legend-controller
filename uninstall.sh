#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
BACKUP_DIR="$STATE_DIR/backups"
TARGET_FILE="$STATE_DIR/target_path"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run this script with sudo."
    echo "Run the uninstall command as your normal user. The script will ask for sudo when needed."
    exit 1
fi

pkill -x OpenRGB >/dev/null 2>&1 || true
pkill -x openrgb >/dev/null 2>&1 || true
sleep 1

if [ -f "$TARGET_FILE" ]; then
    TARGET_BIN="$(cat "$TARGET_FILE")"
else
    TARGET_BIN="/usr/bin/openrgb"
fi

LATEST_BACKUP="$(ls -1t "$BACKUP_DIR"/openrgb.backup.* 2>/dev/null | head -n 1 || true)"

if [ -z "$LATEST_BACKUP" ]; then
    echo "No OpenRGB backup was found."
    echo "Reinstall OpenRGB from your distro package manager if needed."
    exit 1
fi

echo "Restoring OpenRGB backup: $LATEST_BACKUP"
echo "Target: $TARGET_BIN"
sudo install -m 755 "$LATEST_BACKUP" "$TARGET_BIN"

echo "Done. OpenRGB backup restored."
