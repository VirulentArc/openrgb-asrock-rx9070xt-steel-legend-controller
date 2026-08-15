#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
TARGET_FILE="$STATE_DIR/target_path"
BACKUP_FILE="$STATE_DIR/latest_backup"
WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    fail "Do not run this script with sudo. Run it as your normal user."
fi

if [ ! -f "$TARGET_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    fail "No install state was found in $STATE_DIR."
fi

TARGET_BIN="$(cat "$TARGET_FILE")"
BACKUP="$(cat "$BACKUP_FILE")"

[ -f "$BACKUP" ] || fail "Backup binary was not found: $BACKUP"

pkill -x OpenRGB >/dev/null 2>&1 || true
pkill -x openrgb >/dev/null 2>&1 || true
sleep 1

echo "Restoring OpenRGB binary: $TARGET_BIN"
sudo cp -a "$BACKUP" "$TARGET_BIN"
sudo chmod 755 "$TARGET_BIN"

echo "Removing build workspace: $WORKSPACE"
sudo rm -rf "$WORKSPACE"

echo "Done."
