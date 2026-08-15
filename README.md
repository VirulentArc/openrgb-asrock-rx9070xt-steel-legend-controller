# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this folder is added to an OpenRGB source checkout and OpenRGB is rebuilt, the card can be detected as a normal OpenRGB device.

This controller uses the RGB controller that was tested on Linux on the AMDGPU OEM I2C bus at address `0x36`.

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
RGB I2C address: 0x36
Tested OpenRGB I2C bus: 7
```

Known hardware channels:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

This release uses the tested Linux OpenRGB I2C bus detector. The earlier PCI detector experiment has been removed because it did not detect the card on the tested system.

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

This creates one workspace for the OpenRGB source code and this controller source.

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

This removes the old plugin file from the earlier plugin test version.

```text
rm -f "$HOME/.config/OpenRGB/plugins/libOpenRGBASRockRX9070XTPlugin.so"
```

## Step 6: rebuild OpenRGB from source

This builds an OpenRGB binary from the source tree that now contains the Steel Legend controller.

```text
cd "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB"
rm -f OpenRGB openrgb Makefile .qmake.stash
qmake OpenRGB.pro
make -j$(nproc)
```

The rebuilt binary should be:

```text
$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB
```

## Step 7: confirm the rebuilt binary contains the controller

This checks that the Steel Legend controller text exists inside the binary that was just built.

```text
strings "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB" | grep -F "ASRock RX 9070 XT Steel Legend"
```

Expected result:

```text
ASRock RX 9070 XT Steel Legend
```

## Step 8: make the rebuilt OpenRGB the normal OpenRGB command for your user

This copies the rebuilt binary to `$HOME/.local/bin/openrgb`.

On most Linux desktops, `$HOME/.local/bin` is checked before `/usr/bin`, so the normal `openrgb` command will use this rebuilt copy while the distro package remains installed.

```text
mkdir -p "$HOME/.local/bin"
cp "$HOME/.local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB" "$HOME/.local/bin/openrgb"
chmod +x "$HOME/.local/bin/openrgb"
```

Confirm which OpenRGB will run:

```text
command -v openrgb
strings "$(command -v openrgb)" | grep -F "ASRock RX 9070 XT Steel Legend"
```

Expected command path:

```text
$HOME/.local/bin/openrgb
```

Expected controller text:

```text
ASRock RX 9070 XT Steel Legend
```

## Step 9: run OpenRGB normally

This should now launch the rebuilt OpenRGB with the Steel Legend controller included.

```text
openrgb
```

Expected result:

```text
OpenRGB opens
ASRock RX 9070 XT Steel Legend appears as a device
ARGB Header, Top / Side, and Fan appear as zones
```

## Step 10: update autostart

If OpenRGB is already set to start at login, point that autostart entry at the user-local rebuilt OpenRGB binary.

```text
sed -i 's#^Exec=.*#Exec='$HOME'/.local/bin/openrgb --startminimized#' "$HOME/.config/autostart/OpenRGB.desktop"
```

If you use a saved profile, add it back at the end of the `Exec=` line.

Example:

```text
Exec=/home/tim/.local/bin/openrgb --startminimized --profile "Dark"
```

## If the device does not appear

Check whether the controller was actually compiled into the OpenRGB you launched:

```text
command -v openrgb
strings "$(command -v openrgb)" | grep -F "ASRock RX 9070 XT Steel Legend"
```

Check the tested I2C bus exists:

```text
i2cdetect -l | grep -E 'i2c-7|OEM|AMDGPU'
```

The tested working system used:

```text
i2c-7 AMDGPU DM i2c OEM bus
```

## Cleanup

Remove the source workspace:

```text
rm -rf "$HOME/.local/src/openrgb-asrock-steel-legend"
```

Remove the user-local rebuilt OpenRGB command:

```text
rm -f "$HOME/.local/bin/openrgb"
```

After removing the user-local command, the normal `openrgb` command will use the distro package again.

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
