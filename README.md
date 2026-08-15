# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this folder is added to an OpenRGB source checkout and OpenRGB is rebuilt, the card can be detected as a normal OpenRGB device.

This controller matches the tested Steel Legend card by PCI/subsystem ID, then talks to the GPU RGB controller over the AMDGPU OEM I2C bus at address `0x36`.

## Requirements

OpenRGB should already be installed and able to open normally.

Check that first:

```text
openrgb --version
openrgb
```

You also need the normal tools required to build OpenRGB from source:

```text
git
qmake
make
C++ compiler
```

The steps below use one hidden source workspace:

```text
$HOME/.local/src/openrgb-asrock-steel-legend/
```

Everything cloned or built by these instructions goes inside that folder.

## Supported hardware

Tested card:

```text
ASRock Radeon RX 9070 XT Steel Legend 16GB
PCI/device ID:        1002:7550
Subsystem vendor/dev: 1849:5403
RGB I2C address:      0x36
```

Known hardware channels:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

The detector is tied to the tested PCI/subsystem IDs. Users should not need to edit their I2C bus number.

Do not change the PCI IDs, I2C address, channel numbers, or mode values for another GPU unless that card has been tested.

## What this adds to OpenRGB

OpenRGB should show one new device:

```text
ASRock RX 9070 XT Steel Legend
```

OpenRGB zones:

```text
ARGB Header
Top / Side
Fan
```

Hardware modes:

```text
Off
Static
Breathing
Strobe
RGB Cycle
Random
Color Shift
Visor
Stacking
Fill Wave
Traveling Wave
Marquee Color
Marquee Random
Color Wave
Rainbow
```

The speed slider is inverted in the controller code so higher OpenRGB speed means faster animation on this GPU.

## Step 1: create a clean source workspace

This folder is where the OpenRGB source code and this controller source will be placed.

```text
rm -rf "$HOME/.local/src/openrgb-asrock-steel-legend"
mkdir -p "$HOME/.local/src/openrgb-asrock-steel-legend"
cd "$HOME/.local/src/openrgb-asrock-steel-legend"
```

## Step 2: get the tested OpenRGB source code

This downloads the OpenRGB source code into the workspace and checks out the commit this controller was tested with.

```text
git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git
cd "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB"
git checkout 4306603a28c86e91f4dd4f89b41efd3005f0b810
```

Confirm the checked-out commit:

```text
git rev-parse HEAD
```

Expected result:

```text
4306603a28c86e91f4dd4f89b41efd3005f0b810
```

## Step 3: get this Steel Legend controller source

This downloads this controller repository into the same workspace.

```text
cd "$HOME/.local/src/openrgb-asrock-steel-legend"
git clone https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git
```

## Step 4: copy the controller into the OpenRGB source tree

This places the Steel Legend controller folder inside OpenRGB's `Controllers/` folder.

```text
rm -rf "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/Controllers/ASRockRX9070XTGPUController"
cp -a "$HOME/.local/src/openrgb-asrock-steel-legend/openrgb-asrock-rx9070xt-steel-legend-controller/Controllers/ASRockRX9070XTGPUController" "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/Controllers/"
```

OpenRGB's qmake project automatically includes controller source files from the `Controllers/` folder, so no manual `OpenRGB.pro` edit is needed.

## Step 5: remove the old test plugin if it was installed

This native controller replaces the older test plugin approach.

If the old plugin is still installed, OpenRGB may show duplicate devices or crash while loading the stale plugin.

```text
rm -f "$HOME/.config/OpenRGB/plugins/libOpenRGBASRockRX9070XTPlugin.so"
```

## Step 6: rebuild OpenRGB from source

This builds a local OpenRGB binary from the source tree that now contains the Steel Legend controller.

```text
cd "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB"
rm -f OpenRGB openrgb Makefile .qmake.stash
qmake OpenRGB.pro
make
```

The rebuilt binary should be:

```text
$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB
```

## Step 7: run the rebuilt OpenRGB

This starts the OpenRGB binary that was just built from source.

```text
cd "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB"
./OpenRGB
```

Expected result:

```text
OpenRGB opens
ASRock RX 9070 XT Steel Legend appears as a device
ARGB Header, Top / Side, and Fan appear as zones
```

If `./OpenRGB` does not exist, check what was built:

```text
cd "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB"
find . -maxdepth 1 -type f -executable \( -name 'OpenRGB' -o -name 'openrgb' \) -print
```

If the binary is named `openrgb` instead, run:

```text
./openrgb
```

## Optional: create a user-local launcher

This copies the rebuilt OpenRGB binary to a user-local command named `openrgb-asrock`.

```text
mkdir -p "$HOME/.local/bin"
cp "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB" "$HOME/.local/bin/openrgb-asrock"
chmod +x "$HOME/.local/bin/openrgb-asrock"
```

Run it with:

```text
openrgb-asrock
```

If your build produced `openrgb` instead of `OpenRGB`, copy that file instead:

```text
mkdir -p "$HOME/.local/bin"
cp "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/openrgb" "$HOME/.local/bin/openrgb-asrock"
chmod +x "$HOME/.local/bin/openrgb-asrock"
```

## Cleanup

Remove the source workspace:

```text
rm -rf "$HOME/.local/src/openrgb-asrock-steel-legend"
```

Remove the optional user-local launcher:

```text
rm -f "$HOME/.local/bin/openrgb-asrock"
```

## Check the detector

Use this if the Steel Legend device does not appear.

This command shows the AMD GPU and subsystem ID:

```text
lspci -Dnn -vv -d 1002:7550 | grep -Ei 'VGA|Display|Subsystem|Kernel driver'
```

Expected Steel Legend subsystem:

```text
Subsystem: ASRock Incorporation Device [1849:5403]
```

If the subsystem ID is not `1849:5403`, this detector is not expected to attach.

## Low-level packet

The tested RGB packet is:

```text
0x10 0x00 <channel> <mode> <R> <G> <B> <speed> <brightness> <direction> 0x1A 0x00
```

Known channels:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

## Limitations

OpenRGB's normal mode handling is controller-wide. This controller exposes the GPU channels as zones, but OpenRGB's built-in mode selector does not provide independent per-zone hardware modes.

Direct/effects mode is not implemented. This controller uses the tested hardware modes.

## Repository contents

```text
Controllers/
└── ASRockRX9070XTGPUController/
    ├── ASRockRX9070XTGPUController.cpp
    ├── ASRockRX9070XTGPUController.h
    ├── ASRockRX9070XTGPUControllerDetect.cpp
    ├── RGBController_ASRockRX9070XTGPU.cpp
    └── RGBController_ASRockRX9070XTGPU.h
```

## License

The controller source files use `SPDX-License-Identifier: GPL-2.0-or-later` to match OpenRGB project source expectations.
