# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## Requirements

OpenRGB must already be installed and able to open normally before this controller is installed.

The installer rebuilds OpenRGB from source with this controller added, then replaces the normal OpenRGB binary with the rebuilt one.

## Linux distro support

### Arch / CachyOS / Arch-based

This is the main supported installer path. It installs the required build packages with `pacman`, builds OpenRGB, verifies the Steel Legend controller is present, and replaces the normal OpenRGB app binary.

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

The Steel Legend should appear as:

```text
ASRock RX 9070 XT Steel Legend
```

### Debian / Ubuntu

Install the OpenRGB build dependencies first:

```bash
sudo apt update
sudo apt install git build-essential qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools qttools5-dev-tools libusb-1.0-0-dev libhidapi-dev pkgconf libmbedtls-dev i2c-tools python3 curl
```

Then run the controller installer:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

### Fedora

Install the OpenRGB build dependencies first:

```bash
sudo dnf install automake gcc-c++ make git hidapi-devel libusbx-devel mbedtls-devel pkgconf qt5-qtbase-devel qt5-linguist i2c-tools python3 curl
```

Then run the controller installer:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

### openSUSE Tumbleweed / Leap

This path is best effort. Package names can vary between Leap and Tumbleweed.

Install the likely OpenRGB build dependencies first:

```bash
sudo zypper install git gcc-c++ make libqt5-qtbase-devel libqt5-linguist-devel libusb-1_0-devel libhidapi-devel mbedtls-devel pkgconf-pkg-config i2c-tools python3 curl
```

Then run the controller installer:

```bash
curl -fsSL https://raw.githubusercontent.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller/main/install.sh -o /tmp/openrgb-asrock-steel-legend-install.sh && bash /tmp/openrgb-asrock-steel-legend-install.sh
```

Then open OpenRGB normally.

### Other Linux distributions

Install the equivalent packages for your distribution:

```text
Git
C++ build tools
make
Qt5 base development files
Qt5 qmake
Qt5 linguist/tools
libusb 1.0 development files
hidapi development files
mbedTLS development files
pkg-config or pkgconf
i2c-tools
python3
curl
```

Then run the same installer command.

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
