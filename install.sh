#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git"
OPENRGB_URL="https://gitlab.com/CalcProgrammer1/OpenRGB.git"
OPENRGB_COMMIT="4306603a28c86e91f4dd4f89b41efd3005f0b810"
WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"
STATE_DIR="/usr/local/share/openrgb-asrock-steel-legend"
BACKUP_DIR="$STATE_DIR/backups"
OPENRGB_DIR="$WORKSPACE/OpenRGB"
CONTROLLER_REPO_DIR="$WORKSPACE/openrgb-asrock-rx9070xt-steel-legend-controller"
CONTROLLER_DIR="ASRockRX9070XTGPUController"
DEVICE_TEXT="ASRock RX 9070 XT Steel Legend"
DEVICE_LOG="/tmp/openrgb-asrock-devices.log"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run this script with sudo."
    echo "Run the install command as your normal user. The script will ask for sudo when needed."
    exit 1
fi

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1"
        exit 1
    fi
}

stop_openrgb() {
    pkill -x OpenRGB >/dev/null 2>&1 || true
    pkill -x openrgb >/dev/null 2>&1 || true
    sleep 1
}

need_command git
need_command qmake
need_command make
need_command strings
need_command python3
need_command nproc
need_command grep

if [ -x /usr/bin/openrgb ]; then
    TARGET_BIN="/usr/bin/openrgb"
else
    TARGET_BIN="$(command -v openrgb || true)"
fi

if [ -z "$TARGET_BIN" ]; then
    echo "OpenRGB is not installed. Install OpenRGB first, confirm it opens, then run this installer again."
    exit 1
fi

if [ ! -e "$TARGET_BIN" ]; then
    echo "OpenRGB command was found but the target does not exist: $TARGET_BIN"
    exit 1
fi

cd /tmp

echo "Stopping any running OpenRGB process."
stop_openrgb

echo "Installing custom OpenRGB over: $TARGET_BIN"
echo "Build workspace: $WORKSPACE"

sudo rm -rf "$WORKSPACE"
sudo install -d -m 755 -o "$USER" -g "$(id -gn)" "$WORKSPACE"
sudo install -d -m 755 "$BACKUP_DIR"

cd "$WORKSPACE"

echo "Cloning OpenRGB source."
git clone --quiet "$OPENRGB_URL" "$OPENRGB_DIR"

echo "Checking out tested OpenRGB commit."
git -C "$OPENRGB_DIR" checkout --quiet --force "$OPENRGB_COMMIT"

echo "Cloning Steel Legend controller source."
git clone --quiet "$REPO_URL" "$CONTROLLER_REPO_DIR"

SOURCE_CONTROLLER_DIR="$CONTROLLER_REPO_DIR/Controllers/$CONTROLLER_DIR"
BUILD_CONTROLLER_DIR="$OPENRGB_DIR/Controllers/$CONTROLLER_DIR"

if [ ! -d "$SOURCE_CONTROLLER_DIR" ]; then
    echo "Controller source folder not found: $SOURCE_CONTROLLER_DIR"
    exit 1
fi

BUS_ID="${ASROCK_RX9070XT_I2C_BUS:-}"
if [ -z "$BUS_ID" ]; then
    detected_busses=()
    for name_file in /sys/bus/i2c/devices/i2c-*/name; do
        [ -e "$name_file" ] || continue
        if grep -qi 'AMDGPU.*OEM' "$name_file"; then
            bus_name="$(basename "$(dirname "$name_file")")"
            detected_busses+=("${bus_name#i2c-}")
        fi
    done

    if [ "${#detected_busses[@]}" -eq 1 ]; then
        BUS_ID="${detected_busses[0]}"
        echo "Detected AMDGPU OEM I2C bus: $BUS_ID"
    else
        BUS_ID="7"
        echo "Using tested Steel Legend I2C bus: $BUS_ID"
    fi
fi

if ! [[ "$BUS_ID" =~ ^[0-9]+$ ]]; then
    echo "Invalid I2C bus number: $BUS_ID"
    exit 1
fi

echo "Adding Steel Legend controller source to OpenRGB."
rm -rf "$BUILD_CONTROLLER_DIR"
cp -a "$SOURCE_CONTROLLER_DIR" "$OPENRGB_DIR/Controllers/"

BUILD_DETECT_FILE="$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUControllerDetect.cpp"
python3 - "$BUILD_DETECT_FILE" "$BUS_ID" <<'PYTHON_PATCH_BUS'
from pathlib import Path
import re
import sys
path = Path(sys.argv[1])
bus = sys.argv[2]
text = path.read_text()
text, count = re.subn(r'(ASROCK_RX9070XT_TESTED_BUS_ID\s*=\s*)\d+', r'\g<1>' + bus, text, count=1)
if count != 1:
    print(f"Could not set bus number in {path}")
    sys.exit(1)
path.write_text(text)
PYTHON_PATCH_BUS

echo "Rebuilding OpenRGB."
echo "Build output will be written to:"
echo "  /tmp/openrgb-asrock-qmake.log"
echo "  /tmp/openrgb-asrock-build.log"
echo
cd "$OPENRGB_DIR"
make clean >/dev/null 2>&1 || true
rm -f OpenRGB openrgb Makefile .qmake.stash
qmake OpenRGB.pro 2>&1 | tee /tmp/openrgb-asrock-qmake.log
make -j"$(nproc)" 2>&1 | tee /tmp/openrgb-asrock-build.log

BUILT_BIN=""
for candidate in "$OPENRGB_DIR/OpenRGB" "$OPENRGB_DIR/openrgb"; do
    if [ -x "$candidate" ]; then
        BUILT_BIN="$candidate"
        break
    fi
done

if [ -z "$BUILT_BIN" ]; then
    echo "Build finished, but no OpenRGB binary was found."
    echo "Build log: /tmp/openrgb-asrock-build.log"
    exit 1
fi

if ! strings "$BUILT_BIN" | grep -Fq "$DEVICE_TEXT"; then
    echo "The rebuilt OpenRGB binary does not contain the Steel Legend controller."
    echo "The controller was not compiled into OpenRGB."
    echo "Build log: /tmp/openrgb-asrock-build.log"
    exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
if strings "$TARGET_BIN" 2>/dev/null | grep -Fq "$DEVICE_TEXT"; then
    echo "Existing OpenRGB binary already appears to be a Steel Legend custom build."
else
    BACKUP="$BACKUP_DIR/openrgb.backup.$STAMP"
    echo "Backing up existing OpenRGB binary to: $BACKUP"
    sudo cp -a "$TARGET_BIN" "$BACKUP"
fi

printf '%s\n' "$TARGET_BIN" | sudo tee "$STATE_DIR/target_path" >/dev/null
printf '%s\n' "$OPENRGB_COMMIT" | sudo tee "$STATE_DIR/openrgb_commit" >/dev/null
printf '%s\n' "$BUS_ID" | sudo tee "$STATE_DIR/i2c_bus" >/dev/null

sudo install -m 755 "$BUILT_BIN" "$TARGET_BIN"

if ! strings "$TARGET_BIN" | grep -Fq "$DEVICE_TEXT"; then
    echo "Install failed: $TARGET_BIN does not contain the Steel Legend controller after copy."
    exit 1
fi

echo "Stopping any running OpenRGB process before launch."
stop_openrgb

echo "Checking installed OpenRGB device list."
set +e
"$TARGET_BIN" --noautoconnect --list-devices >"$DEVICE_LOG" 2>&1
list_status=$?
set -e

if grep -Fq "$DEVICE_TEXT" "$DEVICE_LOG"; then
    echo "Detected: $DEVICE_TEXT"
else
    echo "The custom OpenRGB binary was installed, but OpenRGB did not detect the Steel Legend."
    echo "Device-list output was saved to: $DEVICE_LOG"
    echo
    cat "$DEVICE_LOG"
    echo
    if [ "$list_status" -ne 0 ]; then
        echo "OpenRGB exited with status $list_status while listing devices."
    fi
    echo "Try forcing the tested bus with:"
    echo "  cd /tmp && curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh | env ASROCK_RX9070XT_I2C_BUS=7 bash"
    exit 1
fi

if [ "$(command -v openrgb || true)" != "$TARGET_BIN" ]; then
    echo "Warning: the openrgb command resolves to: $(command -v openrgb || true)"
    echo "Installed custom binary is: $TARGET_BIN"
fi

echo
echo "Done."
echo "Open OpenRGB normally."
echo "The Steel Legend should appear as: $DEVICE_TEXT"
