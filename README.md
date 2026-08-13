# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

This is **not** a standalone OpenRGB plugin. These files are meant to be copied into an OpenRGB source tree so OpenRGB can be rebuilt with the GPU supported as a native device.

## Replaces the old plugin version

This project originally started as a standalone OpenRGB plugin. That plugin approach was abandoned after testing because it added a separate plugin UI while also registering a device in OpenRGB, which made the setup feel awkward and limited how well the normal OpenRGB controls matched this GPU's channel-based RGB controller.

This native controller version replaces the plugin. The goal is for the ASRock RX 9070 XT Steel Legend to appear as a normal OpenRGB device once the controller is built into OpenRGB.

If you previously installed the test plugin, remove it before testing this native controller so OpenRGB does not show duplicate or conflicting devices.

## Status

Tested on Linux with OpenRGB `0.9+ (git1974)` at commit:

```text
4306603a28c86e91f4dd4f89b41efd3005f0b810
```

The controller appears as one native OpenRGB device:

```text
ASRock RX 9070 XT Steel Legend
```

## Features

- Adds native OpenRGB support for the ASRock RX 9070 XT Steel Legend GPU RGB controller.
- Uses the GPU's I2C RGB controller at address `0x36`.
- Exposes the known hardware channels as OpenRGB zones:
  - `ARGB Header`
  - `Top / Side`
  - `Fan`
- Supports the tested hardware modes:
  - Off
  - Static
  - Breathing
  - Strobe
  - RGB Cycle
  - Random
  - Color Shift
  - Visor
  - Stacking
  - Fill Wave
  - Traveling Wave
  - Marquee Color
  - Marquee Random
  - Color Wave
  - Rainbow
- Corrects OpenRGB speed slider direction so higher speed means faster animation.

## Important notes

This is currently a **local native test implementation**, not an upstream-ready OpenRGB merge request yet.

The current detector uses the known working OpenRGB I2C bus ID from the tested Linux system:

```text
I2C bus ID: 7
I2C address: 0x36
```

That works on the tested system, but it is not a proper hardware detector yet. For upstream OpenRGB support, the detector should be changed to use the GPU's exact PCI/subsystem IDs.

OpenRGB's normal mode handling is controller-wide. This controller exposes the GPU channels as zones, but OpenRGB's built-in mode selector does not provide independent per-zone hardware modes.

## Remove the old plugin first

If you previously tested the standalone plugin version, remove it before testing the native OpenRGB build. Otherwise OpenRGB may show duplicate/conflicting devices.

Linux:

```bash
rm -f ~/.config/OpenRGB/plugins/libOpenRGBASRockRX9070XTPlugin.so
```

Windows plugin builds were not provided, but if one was manually installed, remove it from your OpenRGB plugins folder before testing native support.

## Install into an OpenRGB source tree

Start from an OpenRGB source checkout that matches the OpenRGB version you want to run.

Copy the controller folder into OpenRGB:

```bash
cp -r Controllers/ASRockRX9070XTGPUController ~/OpenRGB/Controllers/
```

Or, from inside this repository:

```bash
cd /path/to/openrgb-asrock-rx9070xt-steel-legend-native
cp -r Controllers/ASRockRX9070XTGPUController ~/OpenRGB/Controllers/
```

## Build OpenRGB

From the OpenRGB source tree:

```bash
cd ~/OpenRGB
qmake OpenRGB.pro
make -j"$(nproc)"
```

Then run the locally built OpenRGB binary for testing:

```bash
./openrgb
```

Do not manually overwrite your system OpenRGB binary. If you want this installed system-wide, use a patched package build or submit the controller upstream to OpenRGB.

## Linux helper commands

Check the OpenRGB version currently installed:

```bash
openrgb --version
```

Get the GPU PCI/subsystem details needed for a proper detector:

```bash
lspci -nn -d 1002:
lspci -nnvv -d 1002:
```

Look for the RX 9070 XT display controller and its subsystem vendor/device IDs.

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

## License

The controller source files use `SPDX-License-Identifier: GPL-2.0-or-later` to match OpenRGB project source expectations.
