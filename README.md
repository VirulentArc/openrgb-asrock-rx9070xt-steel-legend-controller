# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this folder is added to an OpenRGB source checkout and OpenRGB is rebuilt, the card can be detected as a normal OpenRGB device.

This controller matches the tested Steel Legend card by PCI/subsystem ID, then talks to the GPU RGB controller over the AMDGPU OEM I2C bus at address `0x36`.

## Requirements

Before using this repository, OpenRGB should already be installed and able to open normally.

Check that first:

```bash
openrgb --version
openrgb
```

You also need:

```text
git
qmake
make
C++ compiler
OpenRGB source checkout
```

The instructions below use these folders:

```text
~/OpenRGB
    OpenRGB source code. This is the source tree that gets rebuilt.

~/openrgb-asrock-rx9070xt-steel-legend-controller
    This controller repository. Its controller folder gets copied into the OpenRGB source tree.
```

If your folders are somewhere else, replace the paths.

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

## Step 1: get the OpenRGB source code

Clone the tested OpenRGB source version into `~/OpenRGB`:

```bash
cd ~
git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git OpenRGB
cd ~/OpenRGB
git checkout 4306603a28c86e91f4dd4f89b41efd3005f0b810
```

The commit above is the OpenRGB version this controller was tested with.

If you already have `~/OpenRGB`, update or reset it before continuing.

## Step 2: get this controller source

Clone this Steel Legend controller repository into your home folder:

```bash
cd ~
git clone https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git
```

If you already cloned it before, update it instead:

```bash
cd ~/openrgb-asrock-rx9070xt-steel-legend-controller
git pull
```

## Step 3: copy the controller into the OpenRGB source tree

Remove any older copy of this controller from the OpenRGB source tree, then copy in the current controller folder:

```bash
rm -rf ~/OpenRGB/Controllers/ASRockRX9070XTGPUController
cp -a ~/openrgb-asrock-rx9070xt-steel-legend-controller/Controllers/ASRockRX9070XTGPUController       ~/OpenRGB/Controllers/
```

OpenRGB's qmake project automatically includes controller source files from the `Controllers/` folder, so no manual `OpenRGB.pro` edit is needed.

## Step 4: rebuild OpenRGB from source

Build a local OpenRGB binary from `~/OpenRGB` with the Steel Legend controller included:

```bash
cd ~/OpenRGB

make clean 2>/dev/null || true
rm -f OpenRGB openrgb Makefile .qmake.stash

qmake OpenRGB.pro
make
```

The rebuilt binary should be:

```text
~/OpenRGB/OpenRGB
```

## Step 5: run the rebuilt OpenRGB

Run the local source-built OpenRGB binary:

```bash
cd ~/OpenRGB
./OpenRGB
```

Expected result:

```text
OpenRGB opens
ASRock RX 9070 XT Steel Legend appears as a device
ARGB Header, Top / Side, and Fan appear as zones
```

If `./OpenRGB` does not exist, check what was built:

```bash
cd ~/OpenRGB
find . -maxdepth 1 -type f -executable \( -name 'OpenRGB' -o -name 'openrgb' \) -print
```

If the binary is named `openrgb` instead, run:

```bash
./openrgb
```

## Optional: make a separate local launcher

Copy the rebuilt OpenRGB binary to a separate local command named `openrgb-asrock`:

```bash
mkdir -p ~/.local/bin
cp ~/OpenRGB/OpenRGB ~/.local/bin/openrgb-asrock
chmod +x ~/.local/bin/openrgb-asrock
```

Run it with:

```bash
openrgb-asrock
```

If your build produced `~/OpenRGB/openrgb` instead, copy that file instead:

```bash
mkdir -p ~/.local/bin
cp ~/OpenRGB/openrgb ~/.local/bin/openrgb-asrock
chmod +x ~/.local/bin/openrgb-asrock
```

## Remove the old plugin if you tested it

This native controller replaces the older test plugin approach.

If you previously installed the plugin, remove it before running this native build. Otherwise OpenRGB may show duplicate devices or crash while loading the stale plugin.

```bash
rm -f ~/.config/OpenRGB/plugins/libOpenRGBASRockRX9070XTPlugin.so
```

## Check the detector

Use this if the Steel Legend device does not appear.

This command shows the AMD GPU and subsystem ID:

```bash
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
