#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/usr/local/src/openrgb-asrock-steel-legend"
INSTALL_BIN="/usr/local/bin/openrgb"

echo "Removing custom OpenRGB binary: $INSTALL_BIN"
sudo rm -f "$INSTALL_BIN"

echo "Removing source/build workspace: $WORKSPACE"
sudo rm -rf "$WORKSPACE"

echo
echo "Removed. If your distro OpenRGB package is installed, the normal command should now resolve to that package again:"
echo "  command -v openrgb"
