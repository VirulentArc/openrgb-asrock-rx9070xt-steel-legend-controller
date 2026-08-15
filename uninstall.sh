#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"
TARGET_FILE="$STATE_DIR/target_path"
BACKUP_FILE="$STATE_DIR/latest_backup"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    fail "Do not run this script with sudo. Run it as your normal user."
fi

pkill -x OpenRGB >/dev/null 2>&1 || true
pkill -x openrgb >/dev/null 2>&1 || true
sleep 1

if [ -f "$TARGET_FILE" ] && [ -f "$BACKUP_FILE" ]; then
    TARGET_BIN="$(cat "$TARGET_FILE")"
    BACKUP="$(cat "$BACKUP_FILE")"

    if [ -f "$BACKUP" ]; then
        echo "Restoring OpenRGB binary from: $BACKUP"
        sudo cp -a "$BACKUP" "$TARGET_BIN"
        sudo chmod 755 "$TARGET_BIN"
    else
        echo "Backup listed in $BACKUP_FILE was not found: $BACKUP"
        echo "Reinstall OpenRGB with your package manager."
    fi
else
    echo "No saved OpenRGB backup was found."
    echo "Reinstall OpenRGB with your package manager."
fi

echo "Removing build workspace."
sudo rm -rf "$WORKSPACE"

echo "Done."
