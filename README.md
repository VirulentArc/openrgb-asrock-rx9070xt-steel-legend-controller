# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

This is **not** a standalone OpenRGB plugin and it is **not** a drop-in runtime add-on. These files are meant to be copied into an OpenRGB source tree, then OpenRGB must be rebuilt so the GPU is supported as a native OpenRGB device.

## Status

Tested on Linux with OpenRGB source commit:

```text
4306603a28c86e91f4dd4f89b41efd3005f0b810
```

The controller appears as one native OpenRGB device:

```text
ASRock RX 9070 XT Steel Legend
```

This is currently an external native controller source package, not an upstream OpenRGB merge request.

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

The detector is PCI-bound with `REGISTER_I2C_PCI_DETECTOR`, so users should not need to edit their local I2C bus number.

Do **not** change the PCI IDs, I2C address, channels, or mode values for another GPU unless that card has been tested. Sending incorrect I2C data to RGB hardware can cause broken lighting behavior or a controller freeze.

## Features

- Native OpenRGB GPU device, not a plugin device.
- PCI-bound I2C detection for the tested Steel Legend card.
- Zones exposed in OpenRGB:
  - `ARGB Header`
  - `Top / Side`
  - `Fan`
- Hardware modes:
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
- Speed slider is inverted so higher OpenRGB speed means faster animation on this controller.

## Limitations

OpenRGB's normal mode handling is controller-wide. This controller exposes the GPU channels as zones, but OpenRGB's built-in mode selector does not provide independent per-zone hardware modes.

Direct/effects mode is not implemented. This controller is for the tested hardware modes.

## Remove the old plugin first

If you previously tested the standalone plugin version, remove it before testing this native controller. Otherwise OpenRGB may show duplicate or conflicting devices.

Linux:

```bash
rm -f ~/.config/OpenRGB/plugins/libOpenRGBASRockRX9070XTPlugin.so
```

Windows plugin builds were not provided, but if one was manually installed, remove it from your OpenRGB plugins folder before testing native support.

## Linux I2C access

OpenRGB must be able to access the relevant I2C device. On Linux, make sure normal OpenRGB I2C access is working first.

Common checks:

```bash
sudo modprobe i2c-dev
groups
ls -l /dev/i2c-*
```

The user running OpenRGB usually needs access to `/dev/i2c-*`, either through distro OpenRGB udev rules, the `i2c` group, or by running OpenRGB with elevated permissions for testing.

## Install into an OpenRGB source tree

Start with an OpenRGB source checkout. The tested source version is:

```bash
cd ~
git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git OpenRGB
cd ~/OpenRGB
git checkout 4306603a28c86e91f4dd4f89b41efd3005f0b810
```

Clone this controller repository separately:

```bash
cd ~
git clone https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git
```

Copy the controller into the OpenRGB source tree:

```bash
rm -rf ~/OpenRGB/Controllers/ASRockRX9070XTGPUController
cp -a ~/openrgb-asrock-rx9070xt-steel-legend-controller/Controllers/ASRockRX9070XTGPUController \
      ~/OpenRGB/Controllers/
```

OpenRGB's qmake project dynamically includes controller source files under `Controllers/`, so no manual `OpenRGB.pro` edit is needed for this source tree layout.

## Build OpenRGB

From the OpenRGB source tree:

```bash
cd ~/OpenRGB

make clean 2>/dev/null || true
rm -f OpenRGB openrgb Makefile .qmake.stash

qmake OpenRGB.pro
make -j"$(nproc)"
```

The normal local source-build binary is:

```bash
./OpenRGB
```

Some distro or package builds may rename the binary to lowercase `openrgb`, but a direct OpenRGB source build uses `OpenRGB`.

Find the built binary if needed:

```bash
find . -maxdepth 1 -type f -executable \( -name 'OpenRGB' -o -name 'openrgb' \) -print
```

Check for missing shared libraries before launching:

```bash
ldd ./OpenRGB | grep -E 'mbed|not found' || true
```

If `ldd` prints `not found`, rebuild OpenRGB against the libraries currently installed on your system. Do not fix missing ABI libraries by creating manual symlinks.

Launch the local build:

```bash
./OpenRGB
```

Do not manually overwrite `/usr/bin/openrgb`. If you want this installed system-wide, use a patched package build or submit the controller upstream to OpenRGB.

## Validate the detector

Check the GPU PCI/subsystem details:

```bash
lspci -Dnn | grep -Ei 'VGA|Display|3D|AMD|Radeon'
lspci -Dnn -vv -d 1002:7550 | grep -Ei 'VGA|Display|Subsystem|Kernel driver'
```

Expected Steel Legend IDs:

```text
1002:7550 / 1849:5403
```

If the subsystem ID is not `1849:5403`, this detector is not expected to attach.

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
