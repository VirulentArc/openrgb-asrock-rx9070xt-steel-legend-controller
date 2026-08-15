# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this is

This adds ASRock Radeon RX 9070 XT Steel Legend support to OpenRGB.

The installer rebuilds OpenRGB with this native controller, backs up the current OpenRGB binary, and replaces the normal OpenRGB binary with the rebuilt one.

After install, open OpenRGB normally. The card should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

## Install

Run this command:

```bash
cd /tmp && curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh | bash
```

Then open OpenRGB normally.

That is the install process.

## Requirements

OpenRGB must already be installed and able to open normally before running this installer.

The system also needs the normal OpenRGB build tools:

```text
git
qmake
make
C++ compiler
python3
strings
```

On Linux, the user must have I2C access. On many distros that means the user is in the `i2c` group.

## Different I2C bus

The installer tries to find the AMDGPU OEM I2C bus automatically. If detection fails, it uses the tested Steel Legend default bus `7`.

To force a different bus:

```bash
cd /tmp && curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh | env ASROCK_RX9070XT_I2C_BUS=7 bash
```

Replace `7` with the correct bus number from:

```bash
i2cdetect -l
```

## Remove

```bash
cd /tmp && curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh | bash
```

This restores the backed-up OpenRGB binary if a backup is available.

## Supported hardware

Tested card:

```text
ASRock Radeon RX 9070 XT Steel Legend 16GB
RGB I2C address: 0x36
Tested I2C bus: AMDGPU OEM I2C bus
```

Known hardware zones:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

OpenRGB zones:

```text
ARGB Header
Top / Side
Fan
```

## Modes

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

## Notes

This is hardware-mode support only. Direct per-frame LED streaming is not implemented.

The old standalone plugin test version should not be used at the same time as this native controller build.
