# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository adds native OpenRGB support for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

The installer rebuilds OpenRGB with this controller, backs up the current OpenRGB binary, and replaces the normal OpenRGB app binary so the regular OpenRGB launcher uses the custom build.

## Requirements

- ASRock Radeon RX 9070 XT Steel Legend
- Linux with OpenRGB already installed and able to open normally
- Arch, CachyOS, or another pacman-based system for the one-command installer
- I2C access for the current user

## Install

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The device should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

## What the installer does

The installer:

1. Installs the build packages needed to compile OpenRGB.
2. Detects the AMDGPU OEM I2C bus.
3. Confirms the Steel Legend RGB controller address is present.
4. Builds OpenRGB with the Steel Legend controller added.
5. Confirms the rebuilt OpenRGB binary contains the controller.
6. Confirms the rebuilt OpenRGB binary detects the Steel Legend.
7. Backs up the existing OpenRGB binary.
8. Replaces the normal OpenRGB binary.

The detected controller values are saved in:

```text
/usr/local/share/openrgb-asrock-steel-legend/
```

The build workspace is:

```text
/usr/local/src/openrgb-asrock-steel-legend/
```

## Manual bus or address override

The installer normally detects the bus and address automatically.

If needed, force the tested Steel Legend bus:

```bash
ASROCK_RX9070XT_I2C_BUS=7 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

If needed, force both bus and address:

```bash
ASROCK_RX9070XT_I2C_BUS=7 ASROCK_RX9070XT_I2C_ADDR=0x36 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

## Uninstall

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh -o /tmp/openrgb-asrock-steel-legend-uninstall.sh && bash /tmp/openrgb-asrock-steel-legend-uninstall.sh
```

This restores the most recent OpenRGB backup created by the installer.

## Tested card

```text
ASRock Radeon RX 9070 XT Steel Legend
PCI ID: 1002:7550
Subsystem: 1849:5403
RGB I2C address: 0x36
Tested I2C bus on one system: 7
```

## Zones

```text
ARGB Header: channel 3
Top / Side:  channel 6
Fan:         channel 7
```

## Notes

This is native OpenRGB controller source. It is not an OpenRGB plugin.

The controller uses the GPU RGB controller over the AMDGPU OEM I2C bus.
