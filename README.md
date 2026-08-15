# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this folder is added to an OpenRGB source checkout and OpenRGB is rebuilt, the card can be detected as a normal OpenRGB device.

This controller talks to the GPU RGB controller over the AMDGPU OEM I2C bus.

## Supported hardware

Tested target:

```text
ASRock Radeon RX 9070 XT Steel Legend
RGB controller address: 0x36
```

Known zones:

```text
ARGB Header = channel 3
Top / Side  = channel 6
Fan         = channel 7
```

## Requirements

OpenRGB must already be installed and must open normally before running this installer.

The Arch/CachyOS installer installs the build packages it needs, rebuilds OpenRGB with this controller, backs up the existing OpenRGB binary, and replaces the normal OpenRGB app binary.

## Install on Arch, CachyOS, or Arch-based Linux

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The Steel Legend should appear in the device list.

## Manual I2C override

The installer detects the AMDGPU OEM I2C bus and the RGB controller address automatically.

If needed, the bus or address can be forced:

```bash
ASROCK_RX9070XT_I2C_BUS=7 ASROCK_RX9070XT_I2C_ADDR=0x36 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

## Other Linux distributions

The controller source is not Arch-specific, but the one-command installer is written for Arch/CachyOS.

For other distributions, install OpenRGB build dependencies for your distro first, then either adapt `install.sh` or manually copy this controller folder into an OpenRGB source checkout before rebuilding OpenRGB.

The native controller folder is:

```text
Controllers/ASRockRX9070XTGPUController
```

## Uninstall

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh -o /tmp/openrgb-asrock-steel-legend-uninstall.sh && bash /tmp/openrgb-asrock-steel-legend-uninstall.sh
```

This restores the OpenRGB binary that was backed up by the installer.

## Notes

This is native OpenRGB source, not a standalone plugin.

If you previously installed the old test plugin, remove it before using this native controller.
