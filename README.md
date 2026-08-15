# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## Requirements

OpenRGB must already be installed and able to open normally.

This installer is for Linux systems using OpenRGB built from the Qt5/qmake source tree. It was made for the tested ASRock Radeon RX 9070 XT Steel Legend path.

## Install

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The GPU should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

## Manual bus or address override

The installer detects the AMDGPU OEM I2C bus and checks for the RGB controller address.

The tested Steel Legend address is `0x36`.

To force the known tested bus:

```bash
ASROCK_RX9070XT_I2C_BUS=7 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

To force both bus and address:

```bash
ASROCK_RX9070XT_I2C_BUS=7 ASROCK_RX9070XT_I2C_ADDR=0x36 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

## Uninstall

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh -o /tmp/openrgb-asrock-steel-legend-uninstall.sh && bash /tmp/openrgb-asrock-steel-legend-uninstall.sh
```

This restores the OpenRGB binary backed up by the installer.
