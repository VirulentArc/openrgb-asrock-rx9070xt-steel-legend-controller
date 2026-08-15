# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## Requirements

- ASRock Radeon RX 9070 XT Steel Legend.
- Arch Linux or CachyOS.
- OpenRGB already installed and able to open normally.

## Install

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The card should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

## What the installer does

The installer:

1. Installs the build packages needed to compile OpenRGB.
2. Detects the AMDGPU OEM I2C bus.
3. Detects the Steel Legend RGB controller address.
4. Builds OpenRGB with this native controller included.
5. Checks that the rebuilt OpenRGB can see the Steel Legend.
6. Backs up the existing OpenRGB binary.
7. Replaces the normal OpenRGB app binary.

After install, the normal OpenRGB launcher and the normal `openrgb` command use the custom build.

## Manual bus or address override

The installer detects the bus and address automatically.

Only use these if automatic detection fails:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && ASROCK_RX9070XT_I2C_BUS=7 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && ASROCK_RX9070XT_I2C_BUS=7 ASROCK_RX9070XT_I2C_ADDR=0x36 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

## Uninstall

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh -o /tmp/openrgb-asrock-steel-legend-uninstall.sh && bash /tmp/openrgb-asrock-steel-legend-uninstall.sh
```

This restores the OpenRGB binary that was backed up during install.

## Tested hardware

```text
GPU: ASRock Radeon RX 9070 XT Steel Legend
RGB I2C address: 0x36
Known Steel Legend channels:
  3 = ARGB Header
  6 = Top / Side
  7 = Fan
```

## Notes

This controller is for the Steel Legend card only.

Do not use this package for the Taichi. The Taichi has a different channel map and needs different controller handling.
