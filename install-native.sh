#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"
OPENRGB_DIR="$WORKSPACE/OpenRGB"
OPENRGB_COMMIT="4306603a28c86e91f4dd4f89b41efd3005f0b810"
CONTROLLER_DIR="ASRockRX9070XTGPUController"
DEVICE_TEXT="ASRock RX 9070 XT Steel Legend"
INSTALL_BIN="/usr/local/bin/openrgb"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Do not run this script with sudo."
    echo "Run it as your normal user. The script will ask for sudo only when copying to /usr/local/bin."
    exit 1
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONTROLLER_DIR="$REPO_DIR/Controllers/$CONTROLLER_DIR"

if [ ! -d "$SOURCE_CONTROLLER_DIR" ]; then
    echo "Controller source folder not found:"
    echo "$SOURCE_CONTROLLER_DIR"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Missing required command: git"
    exit 1
fi

if ! command -v qmake >/dev/null 2>&1; then
    echo "Missing required command: qmake"
    echo "Install the Qt5 qmake package for your distro, then run this script again."
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "Missing required command: make"
    exit 1
fi

if ! command -v strings >/dev/null 2>&1; then
    echo "Missing required command: strings"
    exit 1
fi

if [ ! -d "$WORKSPACE" ]; then
    echo "Creating source/build workspace: $WORKSPACE"
    sudo install -d -m 755 -o "$USER" -g "$(id -gn)" "$WORKSPACE"
fi

if [ ! -d "$OPENRGB_DIR/.git" ]; then
    echo "Cloning OpenRGB source into: $OPENRGB_DIR"
    git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git "$OPENRGB_DIR"
fi

echo "Checking out tested OpenRGB commit: $OPENRGB_COMMIT"
git -C "$OPENRGB_DIR" fetch --quiet origin
git -C "$OPENRGB_DIR" checkout --force "$OPENRGB_COMMIT"

DETECT_FILE="$SOURCE_CONTROLLER_DIR/ASRockRX9070XTGPUControllerDetect.cpp"
BUILD_DETECT_FILE="$OPENRGB_DIR/Controllers/$CONTROLLER_DIR/ASRockRX9070XTGPUControllerDetect.cpp"

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
        echo "Could not uniquely detect the AMDGPU OEM I2C bus."
        echo "Using tested Steel Legend default bus: $BUS_ID"
        echo "To force a different bus, run: ASROCK_RX9070XT_I2C_BUS=<number> ./install-native.sh"
    fi
fi

if ! [[ "$BUS_ID" =~ ^[0-9]+$ ]]; then
    echo "Invalid bus number: $BUS_ID"
    exit 1
fi

echo "Copying controller source into OpenRGB source tree."
rm -rf "$OPENRGB_DIR/Controllers/$CONTROLLER_DIR"
cp -a "$SOURCE_CONTROLLER_DIR" "$OPENRGB_DIR/Controllers/"

python3 - "$BUILD_DETECT_FILE" "$BUS_ID" <<'PY'
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
PY

echo "Controller build bus is set to: $BUS_ID"

echo "Rebuilding OpenRGB."
cd "$OPENRGB_DIR"
make clean >/dev/null 2>&1 || true
rm -f OpenRGB openrgb Makefile .qmake.stash
qmake OpenRGB.pro
make -j"$(nproc)"

BUILT_BIN=""
for candidate in "$OPENRGB_DIR/OpenRGB" "$OPENRGB_DIR/openrgb"; do
    if [ -x "$candidate" ]; then
        BUILT_BIN="$candidate"
        break
    fi
done

if [ -z "$BUILT_BIN" ]; then
    echo "Build finished, but no OpenRGB binary was found."
    echo "Look in: $OPENRGB_DIR"
    exit 1
fi

echo "Built binary: $BUILT_BIN"

if ! strings "$BUILT_BIN" | grep -Fq "$DEVICE_TEXT"; then
    echo "The rebuilt OpenRGB binary does not contain the Steel Legend controller text."
    echo "The controller was not compiled into OpenRGB."
    exit 1
fi

echo "Installing rebuilt OpenRGB binary to: $INSTALL_BIN"
sudo install -m 755 "$BUILT_BIN" "$INSTALL_BIN"

echo
echo "Installed."
echo "Run this to confirm the normal command points to the custom build:"
echo "  command -v openrgb"
echo "Expected path:"
echo "  $INSTALL_BIN"
echo
echo "Then run:"
echo "  openrgb"
