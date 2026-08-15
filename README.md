# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this is

This repository adds native OpenRGB support for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

The controller is compiled into OpenRGB. After installation, OpenRGB opens normally from the existing app menu, autostart entry, or `openrgb` command.

## Supported hardware

Tested target:

```text
ASRock Radeon RX 9070 XT Steel Legend
RGB controller on the AMDGPU OEM I2C bus
Default RGB controller address: 0x36
```

Known zones:

```text
ARGB Header = channel 3
Top / Side  = channel 6
Fan         = channel 7
```

## Platform support

The controller source is for Linux OpenRGB builds.

The installer currently supports Arch-based distributions, including CachyOS and Arch Linux. It uses `pacman` to install build dependencies, rebuilds OpenRGB with this controller added, then replaces the installed OpenRGB binary.

Other Linux distributions may work, but they need the equivalent OpenRGB build dependencies installed manually. See the distro dependency notes below.

Windows is not supported by this installer.

## Install

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

## Manual bus or address override

The installer tries to detect the AMDGPU OEM I2C bus and confirms the RGB controller address.

Known Steel Legend default:

```text
address 0x36
```

To force a bus:

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

This restores the OpenRGB binary that was backed up during install.

## Distro dependency notes

The one-command installer handles these automatically on Arch-based distributions.

For other Linux distributions, install the equivalent OpenRGB build dependencies before using the source manually.

Debian / Ubuntu:

```bash
sudo apt install git build-essential pkgconf qtbase5-dev qttools5-dev-tools libusb-1.0-0-dev libhidapi-dev libmbedtls-dev i2c-tools
```

Fedora:

```bash
sudo dnf install git gcc-c++ make pkgconf-pkg-config qt5-qtbase-devel qt5-linguist hidapi-devel libusbx-devel mbedtls-devel i2c-tools
```

openSUSE:

```bash
sudo zypper install git gcc-c++ make pkgconf-pkg-config libqt5-qtbase-devel libqt5-linguist libusb-1_0-devel hidapi-devel mbedtls-devel i2c-tools
```

## Build notes

The installer builds OpenRGB from this tested commit:

```text
4306603a28c86e91f4dd4f89b41efd3005f0b810
```

The installer copies the controller into the OpenRGB source tree, then patches OpenRGB.pro at the controller discovery section so qmake includes these exact Steel Legend source files.

Build files are placed under:

```text
/usr/local/src/openrgb-asrock-steel-legend
```

Install state and binary backups are placed under:

```text
/usr/local/share/openrgb-asrock-steel-legend
```

The installed OpenRGB binary is replaced at:

```text
/usr/bin/openrgb
```

## Logs

The installer writes build logs here:

```text
/tmp/openrgb-asrock-qmake.log
/tmp/openrgb-asrock-build.log
/tmp/openrgb-asrock-devices.log
```

## License

GPL-2.0-or-later, matching OpenRGB.
