# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## Requirements

OpenRGB must already be installed and able to open normally.

On Arch/CachyOS, the installer will install the build packages it needs.

## Install

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The Steel Legend should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

## Manual bus/address override

The installer detects the AMDGPU OEM I2C bus and confirms the tested Steel Legend address, `0x36`.

If detection needs to be forced:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && ASROCK_RX9070XT_I2C_BUS=7 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

To force both bus and address:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && ASROCK_RX9070XT_I2C_BUS=7 ASROCK_RX9070XT_I2C_ADDR=0x36 bash /tmp/openrgb-asrock-steel-legend-install.sh
```

## Uninstall

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/uninstall.sh -o /tmp/openrgb-asrock-steel-legend-uninstall.sh && bash /tmp/openrgb-asrock-steel-legend-uninstall.sh
```

## Notes

The installer rebuilds OpenRGB with this controller compiled in, backs up the current OpenRGB binary, and replaces the normal OpenRGB binary so the normal app launcher runs the rebuilt version.

Build files are placed under:

```text
/usr/local/src/openrgb-asrock-steel-legend
```

Backup metadata is placed under:

```text
/usr/local/share/openrgb-asrock-steel-legend
```

## Tested hardware path

```text
GPU: ASRock Radeon RX 9070 XT Steel Legend
RGB I2C address: 0x36
Known working bus on the original test system: 7
Channels:
  3 = ARGB Header
  6 = Top / Side
  7 = Fan
```
