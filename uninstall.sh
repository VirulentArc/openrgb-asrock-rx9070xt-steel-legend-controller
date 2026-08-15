#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
TARGET_FILE="$STATE_DIR/target_path"
BACKUP_FILE="$STATE_DIR/latest_backup"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    fail "Do not run this script with sudo. Run it as your normal user."
fi

[ -f "$TARGET_FILE" ] || fail "No installed target record found."
[ -f "$BACKUP_FILE" ] || fail "No backup record found."

TARGET_BIN="$(cat "$TARGET_FILE")"
BACKUP="$(cat "$BACKUP_FILE")"

[ -f "$BACKUP" ] || fail "Backup binary not found: $BACKUP"

pkill -x OpenRGB >/dev/null 2>&1 || true
pkill -x openrgb >/dev/null 2>&1 || true
sleep 1

echo "Restoring OpenRGB binary from: $BACKUP"
sudo cp -a "$BACKUP" "$TARGET_BIN"

echo "Removing build workspace."
sudo rm -rf /usr/local/src/openrgb-asrock-steel-legend

echo "Done."
