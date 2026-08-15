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
SOURCE_CONTROLLER_DIR="$CONTROLLER_REPO_DIR/Controllers/$CONTROLLER_DIR"
BUILD_CONTROLLER_DIR="$OPENRGB_DIR/Controllers/$CONTROLLER_DIR"
DEVICE_TEXT="ASRock RX 9070 XT Steel Legend"
KNOWN_ADDRESS="0x36"
TARGET_BIN="/usr/bin/openrgb"
QMAKE_LOG="/tmp/openrgb-asrock-qmake.log"
BUILD_LOG="/tmp/openrgb-asrock-build.log"
DEVICE_LOG="/tmp/openrgb-asrock-devices.log"
QMAKE=""
BUS_ID=""
I2C_ADDR=""

CONTROLLER_SOURCES=(
    ASRockRX9070XTGPUController.cpp
    ASRockRX9070XTGPUControllerDetect.cpp
    RGBController_ASRockRX9070XTGPU.cpp
)
CONTROLLER_HEADERS=(
    ASRockRX9070XTGPUController.h
    RGBController_ASRockRX9070XTGPU.h
)

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

    local qt_version
    qt_version="$($QMAKE -query QT_VERSION 2>/dev/null || true)"
    case "$qt_version" in
        5.*) ;;
        *) fail "$QMAKE is not Qt5 qmake. Found Qt version: ${qt_version:-unknown}" ;;
    esac
}

install_arch_build_packages() {
    if ! command -v pacman >/dev/null 2>&1; then
        echo "pacman was not found. Automatic dependency install is only supported on Arch-based distributions."
        echo "Install OpenRGB build dependencies for your distribution, then run this installer again."
        return
    fi

    echo "Installing required build packages."
    sudo pacman -S --needed --noconfirm \
        base-devel git pkgconf qt5-base qt5-tools libusb hidapi i2c-tools mbedtls3
}

patch_openrgb_mbedtls_paths() {
    local project_file="$1"

    if [ -f /usr/include/mbedtls/ctr_drbg.h ]; then
        echo "Using mbedTLS headers from /usr/include."
        return
    fi

    if [ -f /usr/include/mbedtls3/mbedtls/ctr_drbg.h ]; then
        echo "Using mbedTLS compatibility headers from /usr/include/mbedtls3."
        python3 - "$project_file" <<'PYTHON_MBEDTLS'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
block = '''
# ASRock RX 9070 XT Steel Legend installer: mbedTLS compatibility paths
INCLUDEPATH += /usr/include/mbedtls3
LIBS += -L/usr/lib/mbedtls3
'''
if 'INCLUDEPATH += /usr/include/mbedtls3' not in text:
    text = text.rstrip() + '\n\n' + block
path.write_text(text)
PYTHON_MBEDTLS
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
    local scan_output=""

    if scan_output="$(i2cdetect -y "$bus" 2>/dev/null)"; then
        :
    elif scan_output="$(sudo i2cdetect -y "$bus" 2>/dev/null)"; then
        :
    else
        return 1
    fi

    awk '
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
        }' <<<"$scan_output"
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

        if [ -z "$bus" ] && [ "${#oem_busses[@]}" -eq 1 ]; then
            bus="${oem_busses[0]}"
        fi

        if [ -z "$bus" ]; then
            echo "More than one AMDGPU OEM I2C bus was found, and address $KNOWN_ADDRESS was not detected."
            for candidate_bus in "${oem_busses[@]}"; do
                print_i2c_bus "$candidate_bus"
            done
            fail "Set ASROCK_RX9070XT_I2C_BUS=<number> and run the installer again."
        fi
    fi

    if [ -n "$manual_addr" ]; then
        addr="$(normalize_addr "$manual_addr")"
    elif address_is_on_bus "$bus" "$KNOWN_ADDRESS"; then
        addr="$KNOWN_ADDRESS"
    else
        echo "Address $KNOWN_ADDRESS was not detected on I2C bus $bus."
        print_i2c_bus "$bus"
        fail "Set ASROCK_RX9070XT_I2C_ADDR=<hex address> if this Steel Legend uses a different RGB controller address."
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
    local controller_file="$3"
    local bus="$4"
    local addr="$5"

    python3 - "$detect_file" "$header_file" "$controller_file" "$bus" "$addr" <<'PYTHON_PATCH_SOURCE'
from pathlib import Path
import re
import sys

detect_path = Path(sys.argv[1])
header_path = Path(sys.argv[2])
controller_path = Path(sys.argv[3])
bus = sys.argv[4]
addr = sys.argv[5]

detect_text = detect_path.read_text()
detect_text, bus_count = re.subn(
    r'(ASROCK_RX9070XT_TEST(?:ED)?_BUS_ID\s*=\s*)\d+',
    r'\g<1>' + bus,
    detect_text,
    count=1,
)
if bus_count != 1:
    print(f"Could not set bus number in {detect_path}")
    sys.exit(1)
detect_path.write_text(detect_text)

header_text = header_path.read_text()
header_text, addr_count = re.subn(
    r'(I2C_ADDRESS\s*=\s*)0x[0-9A-Fa-f]+',
    r'\g<1>' + addr,
    header_text,
    count=1,
)
if addr_count != 1:
    print(f"Could not set I2C address in {header_path}")
    sys.exit(1)
header_path.write_text(header_text)

controller_text = controller_path.read_text()
controller_text = re.sub(
    r'" addr 0x[0-9A-Fa-f]+"',
    f'" addr {addr}"',
    controller_text,
)
controller_path.write_text(controller_text)
PYTHON_PATCH_SOURCE
}

verify_controller_source_files() {
    local dir="$1"
    local file

    [ -d "$dir" ] || fail "Controller source folder not found: $dir"

    for file in "${CONTROLLER_SOURCES[@]}" "${CONTROLLER_HEADERS[@]}"; do
        [ -f "$dir/$file" ] || fail "Missing controller source file: $dir/$file"
    done
}

patch_openrgb_project_file() {
    local project_file="$1"

    python3 - "$project_file" <<'PYTHON_PATCH_PROJECT'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
start = '# BEGIN ASRock RX 9070 XT Steel Legend native controller'
end = '# END ASRock RX 9070 XT Steel Legend native controller'
if start in text:
    before = text.split(start)[0].rstrip()
    after = text.split(end, 1)[1].lstrip() if end in text else ''
    text = before + '\n' + after

block = r'''
# BEGIN ASRock RX 9070 XT Steel Legend native controller
CONTROLLER_H -= \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.h \
    Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.h
CONTROLLER_CPP -= \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.cpp \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUControllerDetect.cpp \
    Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.cpp
CONTROLLER_H += \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.h \
    Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.h
CONTROLLER_CPP += \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.cpp \
    Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUControllerDetect.cpp \
    Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.cpp
# END ASRock RX 9070 XT Steel Legend native controller
'''.strip()

needle = 'CONTROLLER_CPP      = $$files("Controllers/*.cpp", true)'
if needle not in text:
    print(f'Could not find OpenRGB controller discovery line in {path}')
    sys.exit(1)
text = text.replace(needle, needle + '\n\n' + block, 1)
path.write_text(text)
PYTHON_PATCH_PROJECT
}

install_controller_sources_inside_openrgb() {
    echo "Adding Steel Legend controller source to OpenRGB."
    rm -rf "$BUILD_CONTROLLER_DIR"
    cp -a "$SOURCE_CONTROLLER_DIR" "$OPENRGB_DIR/Controllers/"
}

verify_makefile_contains_controller() {
    local makefile="$1"
    local missing=0
    local src

    [ -f "$makefile" ] || fail "qmake did not create a Makefile. qmake log: $QMAKE_LOG"

    for src in "${CONTROLLER_SOURCES[@]}"; do
        if ! grep -Fq "Controllers/ASRockRX9070XTGPUController/$src" "$makefile"; then
            echo "Missing from generated Makefile: Controllers/ASRockRX9070XTGPUController/$src" >&2
            missing=1
        fi
    done

    [ "$missing" -eq 0 ] || fail "qmake did not add the Steel Legend controller source files to the OpenRGB build. qmake log: $QMAKE_LOG"
}

verify_object_files_built() {
    local missing=0
    local obj
    for obj in ASRockRX9070XTGPUController.o ASRockRX9070XTGPUControllerDetect.o RGBController_ASRockRX9070XTGPU.o; do
        if ! find "$OPENRGB_DIR" -type f -name "$obj" | grep -q .; then
            echo "Missing object file after build: $obj" >&2
            missing=1
        fi
    done
    [ "$missing" -eq 0 ] || fail "The Steel Legend controller source was not compiled. Build log: $BUILD_LOG"
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

show_link_errors_if_any() {
    if grep -E 'undefined reference|multiple definition|ld returned|collect2:' "$BUILD_LOG" >/dev/null 2>&1; then
        echo "Relevant linker/compiler errors from $BUILD_LOG:"
        grep -E 'undefined reference|multiple definition|ld returned|collect2:' "$BUILD_LOG" || true
    fi
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    fail "Do not run this script with sudo. Run the install command as your normal user."
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
need_command find

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

verify_controller_source_files "$SOURCE_CONTROLLER_DIR"
install_controller_sources_inside_openrgb

patch_controller_bus_and_address \
    "$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUControllerDetect.cpp" \
    "$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUController.h" \
    "$BUILD_CONTROLLER_DIR/ASRockRX9070XTGPUController.cpp" \
    "$BUS_ID" \
    "$I2C_ADDR"

patch_openrgb_project_file "$OPENRGB_DIR/OpenRGB.pro"
patch_openrgb_mbedtls_paths "$OPENRGB_DIR/OpenRGB.pro"

echo "Rebuilding OpenRGB."
echo "Build logs:"
echo "  $QMAKE_LOG"
echo "  $BUILD_LOG"
cd "$OPENRGB_DIR"
make clean >/dev/null 2>&1 || true
rm -f OpenRGB openrgb Makefile .qmake.stash

"$QMAKE" OpenRGB.pro 2>&1 | tee "$QMAKE_LOG"
verify_makefile_contains_controller Makefile

set +e
make -j"$(nproc)" 2>&1 | tee "$BUILD_LOG"
make_status=${PIPESTATUS[0]}
set -e
if [ "$make_status" -ne 0 ]; then
    show_link_errors_if_any
    fail "OpenRGB build failed. Build log: $BUILD_LOG"
fi

verify_object_files_built

BUILT_BIN="$(find_built_binary || true)"
[ -n "$BUILT_BIN" ] || fail "Build finished, but no OpenRGB binary was found. Build log: $BUILD_LOG"

if strings "$BUILT_BIN" | grep -Fq "$DEVICE_TEXT"; then
    echo "Verified Steel Legend marker in rebuilt binary."
else
    echo "WARNING: The rebuilt binary did not show the Steel Legend marker with strings."
    echo "The Steel Legend object files were built, so installation will continue."
fi

echo "Checking rebuilt OpenRGB device list."
set +e
"$BUILT_BIN" --noautoconnect --list-devices >"$DEVICE_LOG" 2>&1
list_status=$?
set -e
if grep -Fq "$DEVICE_TEXT" "$DEVICE_LOG"; then
    echo "Detected by rebuilt OpenRGB: $DEVICE_TEXT"
else
    echo "The command-line device scan did not list the Steel Legend."
    echo "The install will continue so the normal OpenRGB app can be opened and checked."
    echo "Device scan log: $DEVICE_LOG"
    [ "$list_status" -eq 0 ] || echo "OpenRGB exited with status $list_status while listing devices."
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

stop_openrgb

echo "Done. Open OpenRGB normally."
