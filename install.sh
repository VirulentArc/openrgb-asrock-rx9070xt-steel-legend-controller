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
KNOWN_ADDRESS="0x36"
TARGET_BIN="/usr/bin/openrgb"
QMAKE_LOG="/tmp/openrgb-asrock-qmake.log"
BUILD_LOG="/tmp/openrgb-asrock-build.log"
DEVICE_LOG="/tmp/openrgb-asrock-devices.log"
QMAKE=""
BUS_ID=""
I2C_ADDR=""

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

stop_openrgb() {
    pkill -x OpenRGB >/dev/null 2>&1 || true
    pkill -x openrgb >/dev/null 2>&1 || true
    sleep 1
}

pick_qmake() {
    if command -v qmake >/dev/null 2>&1; then
        QMAKE="qmake"
    elif command -v qmake-qt5 >/dev/null 2>&1; then
        QMAKE="qmake-qt5"
    else
        fail "Qt5 qmake was not found."
    fi

    qt_version="$($QMAKE -query QT_VERSION 2>/dev/null || true)"
    case "$qt_version" in
        5.*) ;;
        *) fail "$QMAKE is not Qt5 qmake. Found Qt version: ${qt_version:-unknown}" ;;
    esac
}

install_arch_build_packages() {
    if ! command -v pacman >/dev/null 2>&1; then
        return
    fi

    echo "Installing required build packages."
    sudo pacman -S --needed --noconfirm \
        base-devel git pkgconf qt5-base qt5-tools libusb hidapi i2c-tools

    if pacman -Si mbedtls3 >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm mbedtls3
    else
        sudo pacman -S --needed --noconfirm mbedtls
    fi
}

patch_openrgb_mbedtls_paths() {
    local project_file="$1"

    if [ -f /usr/include/mbedtls/ctr_drbg.h ]; then
        echo "Using mbedTLS headers from /usr/include."
        return
    fi

    if [ -f /usr/include/mbedtls3/mbedtls/ctr_drbg.h ]; then
        echo "Using mbedTLS 3 compatibility headers from /usr/include/mbedtls3."
        python3 - "$project_file" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace('/usr/include/mbedtls/', '/usr/include/mbedtls3/')
text = text.replace('-L/usr/lib/mbedtls/', '-L/usr/lib/mbedtls3/')
path.write_text(text)
PY
        return
    fi

    echo "Checked for:"
    echo "  /usr/include/mbedtls/ctr_drbg.h"
    echo "  /usr/include/mbedtls3/mbedtls/ctr_drbg.h"
    fail "mbedTLS headers were not found."
}

normalize_bus() {
    local bus="$1"
    [[ "$bus" =~ ^[0-9]+$ ]] || fail "Invalid I2C bus number: $bus"
    printf '%s\n' "$bus"
}

normalize_addr() {
    local addr="${1,,}"
    addr="${addr#0x}"
    [[ "$addr" =~ ^[0-7][0-9a-f]$ ]] || fail "Invalid 7-bit I2C address: $1"
    printf '0x%s\n' "$addr"
}

scan_i2c_addresses() {
    local bus="$1"
    i2cdetect -y "$bus" 2>/dev/null | awk '
        NR > 1 && $1 ~ /^[0-7][0-9a-fA-F]:$/ {
            row = substr($1, 1, 1)
            for(i = 2; i <= NF; i++) {
                token = tolower($i)
                col = i - 2
                addr = sprintf("0x%s%x", row, col)
                if(token ~ /^[0-9a-f][0-9a-f]$/ || token == "uu") {
                    print addr
                }
            }
        }'
}

address_is_on_bus() {
    local bus="$1"
    local addr="$2"
    scan_i2c_addresses "$bus" | grep -Fxq "$addr"
}

find_oem_busses() {
    local name_file bus_name
    for name_file in /sys/bus/i2c/devices/i2c-*/name; do
        [ -e "$name_file" ] || continue
        if grep -qi 'AMDGPU.*OEM' "$name_file"; then
            bus_name="$(basename "$(dirname "$name_file")")"
            printf '%s\n' "${bus_name#i2c-}"
        fi
    done
}

print_i2c_bus() {
    local bus="$1"
    echo "i2cdetect output for bus $bus:"
    i2cdetect -y "$bus" || true
    echo
}

detect_bus_and_address() {
    local manual_bus="${ASROCK_RX9070XT_I2C_BUS:-}"
    local manual_addr="${ASROCK_RX9070XT_I2C_ADDR:-}"
    local bus=""
    local addr=""

    if [ -n "$manual_bus" ]; then
        bus="$(normalize_bus "$manual_bus")"
    else
        mapfile -t oem_busses < <(find_oem_busses)
        [ "${#oem_busses[@]}" -gt 0 ] || fail "No AMDGPU OEM I2C bus was found."

        for candidate_bus in "${oem_busses[@]}"; do
            if address_is_on_bus "$candidate_bus" "$KNOWN_ADDRESS"; then
                bus="$candidate_bus"
                break
            fi
        done

        if [ -z "$bus" ]; then
            echo "AMDGPU OEM I2C bus was found, but address $KNOWN_ADDRESS was not detected."
            for candidate_bus in "${oem_busses[@]}"; do
                print_i2c_bus "$candidate_bus"
            done
            fail "Steel Legend RGB controller address was not detected."
        fi
    fi

    if [ -n "$manual_addr" ]; then
        addr="$(normalize_addr "$manual_addr")"
    else
        addr="$KNOWN_ADDRESS"
    fi

    if ! address_is_on_bus "$bus" "$addr"; then
        print_i2c_bus "$bus"
        fail "Address $addr was not detected on I2C bus $bus."
    fi

    BUS_ID="$bus"
    I2C_ADDR="$addr"
}

patch_controller_bus_and_address() {
    local detect_file="$1"
    local header_file="$2"
    local bus="$3"
    local addr="$4"

    python3 - "$detect_file" "$header_file" "$bus" "$addr" <<'PY'
from pathlib import Path
import re
import sys

detect_path = Path(sys.argv[1])
header_path = Path(sys.argv[2])
bus = sys.argv[3]
addr = sys.argv[4]

detect_text = detect_path.read_text()
detect_text, count = re.subn(
    r'(ASROCK_RX9070XT_TEST_BUS_ID\s*=\s*)\d+',
    r'\g<1>' + bus,
    detect_text,
    count=1,
)
if count != 1:
    print(f"Could not patch bus ID in {detect_path}")
    sys.exit(1)
detect_path.write_text(detect_text)

header_text = header_path.read_text()
header_text, count = re.subn(
    r'(I2C_ADDRESS\s*=\s*)0x[0-9A-Fa-f]+',
    r'\g<1>' + addr,
    header_text,
    count=1,
)
if count != 1:
    print(f"Could not patch I2C address in {header_path}")
    sys.exit(1)
header_path.write_text(header_text)
PY
}

verify_controller_source_files() {
    local dir="$1"
    for file in \
        ASRockRX9070XTGPUController.cpp \
        ASRockRX9070XTGPUController.h \
        ASRockRX9070XTGPUControllerDetect.cpp \
        RGBController_ASRockRX9070XTGPU.cpp \
        RGBController_ASRockRX9070XTGPU.h
    do
        [ -f "$dir/$file" ] || fail "Missing controller source file: $dir/$file"
    done
}

find_built_binary() {
    for candidate in "$OPENRGB_DIR/openrgb" "$OPENRGB_DIR/OpenRGB"; do
        if [ -x "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    fail "Do not run this script with sudo. Run it as your normal user."
fi

cd /tmp

need_command sudo
need_command git
need_command make
need_command strings
need_command python3
need_command nproc
need_command grep
need_command awk
need_command sed

install_arch_build_packages

need_command i2cdetect
pick_qmake
[ -x "$TARGET_BIN" ] || fail "OpenRGB is not installed at $TARGET_BIN. Install OpenRGB first, confirm it opens, then run this installer again."

stop_openrgb

if command -v modprobe >/dev/null 2>&1; then
    sudo modprobe i2c-dev >/dev/null 2>&1 || true
fi

echo "Detecting Steel Legend RGB controller."
detect_bus_and_address
echo "Detected I2C bus: $BUS_ID"
echo "Detected I2C address: $I2C_ADDR"

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

verify_controller_source_files "$SOURCE_CONTROLLER_DIR"

echo "Adding Steel Legend controller source to OpenRGB."
rm -rf "$BUILD_CONTROLLER_DIR"
cp -a "$SOURCE_CONTROLLER_DIR" "$OPENRGB_DIR/Controllers/"

patch_controller_bus_and_address \
    "$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUControllerDetect.cpp" \
    "$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUController.h" \
    "$BUS_ID" \
    "$I2C_ADDR"

patch_openrgb_mbedtls_paths "$OPENRGB_DIR/OpenRGB.pro"

echo "Rebuilding OpenRGB."
echo "Build logs:"
echo "  $QMAKE_LOG"
echo "  $BUILD_LOG"
cd "$OPENRGB_DIR"
make clean >/dev/null 2>&1 || true
rm -f OpenRGB openrgb Makefile .qmake.stash

"$QMAKE" OpenRGB.pro 2>&1 | tee "$QMAKE_LOG"

if ! grep -Fq "$CONTROLLER_DIR/ASRockRX9070XTGPUController.cpp" Makefile; then
    fail "qmake did not include the Steel Legend controller source. qmake log: $QMAKE_LOG"
fi

make -j"$(nproc)" 2>&1 | tee "$BUILD_LOG"

BUILT_BIN="$(find_built_binary || true)"
[ -n "$BUILT_BIN" ] || fail "Build finished, but no OpenRGB binary was found. Build log: $BUILD_LOG"

if ! strings "$BUILT_BIN" | grep -Fq "$DEVICE_TEXT"; then
    fail "The rebuilt OpenRGB binary does not contain the Steel Legend controller. Build log: $BUILD_LOG"
fi

echo "Checking the rebuilt OpenRGB device list before replacing the installed app."
set +e
"$BUILT_BIN" --noautoconnect --list-devices >"$DEVICE_LOG" 2>&1
list_status=$?
set -e

if ! grep -Fq "$DEVICE_TEXT" "$DEVICE_LOG"; then
    echo "The rebuilt OpenRGB binary contains the controller, but did not detect the Steel Legend."
    echo "Device-list output:"
    cat "$DEVICE_LOG"
    echo
    [ "$list_status" -eq 0 ] || echo "OpenRGB exited with status $list_status while listing devices."
    fail "Install stopped before replacing $TARGET_BIN."
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BACKUP_DIR/openrgb.backup.$STAMP"
echo "Backing up current OpenRGB binary to: $BACKUP"
sudo cp -a "$TARGET_BIN" "$BACKUP"

printf '%s\n' "$TARGET_BIN" | sudo tee "$STATE_DIR/target_path" >/dev/null
printf '%s\n' "$OPENRGB_COMMIT" | sudo tee "$STATE_DIR/openrgb_commit" >/dev/null
printf '%s\n' "$BUS_ID" | sudo tee "$STATE_DIR/i2c_bus" >/dev/null
printf '%s\n' "$I2C_ADDR" | sudo tee "$STATE_DIR/i2c_address" >/dev/null
printf '%s\n' "$BACKUP" | sudo tee "$STATE_DIR/latest_backup" >/dev/null

echo "Replacing installed OpenRGB app: $TARGET_BIN"
sudo install -m 755 "$BUILT_BIN" "$TARGET_BIN"

if ! strings "$TARGET_BIN" | grep -Fq "$DEVICE_TEXT"; then
    sudo cp -a "$BACKUP" "$TARGET_BIN"
    fail "Install failed after copy. The original OpenRGB binary was restored."
fi

stop_openrgb

echo
echo "Done."
echo "Open OpenRGB normally."
echo "The device should appear as: $DEVICE_TEXT"
