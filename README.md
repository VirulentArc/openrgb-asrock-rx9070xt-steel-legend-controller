# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is compiled into OpenRGB. After this installer rebuilds OpenRGB with the controller added, OpenRGB can detect the card as a normal OpenRGB device.

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

For other distributions, install OpenRGB build dependencies for your distro first, then either adapt `install.sh` or manually copy this controller source into an OpenRGB source checkout before rebuilding OpenRGB.

The native controller files are:

```text
Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.cpp
Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUController.h
Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUControllerDetect.cpp
Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.cpp
Controllers/ASRockRX9070XTGPUController/RGBController_ASRockRX9070XTGPU.h
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
