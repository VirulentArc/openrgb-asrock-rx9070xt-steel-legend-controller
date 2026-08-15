# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this controller is compiled into OpenRGB, the card can appear as a normal OpenRGB device.

This controller talks to the GPU RGB controller over the AMDGPU OEM I2C bus at address `0x36`.

## Requirements

OpenRGB should already be installed and able to open normally.

You also need the normal tools required to build OpenRGB from source:

```text
git
qmake
make
C++ compiler
strings
```

On Linux, your user also needs I2C access. On many distros that means the user is in the `i2c` group.

## Supported hardware

Tested card:

```text
ASRock Radeon RX 9070 XT Steel Legend 16GB
RGB I2C address: 0x36
Tested RGB controller bus: AMDGPU OEM I2C bus
```

Known hardware channels:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

## What this adds to OpenRGB

OpenRGB should show one new device:

```text
ASRock RX 9070 XT Steel Legend
```

OpenRGB zones:

```text
ARGB Header
Top / Side
Fan
```

Hardware modes:

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

The speed slider is inverted in the controller code so higher OpenRGB speed means faster animation on this GPU.

## Install

These commands create one source/build workspace in `/usr/local/src/openrgb-asrock-steel-legend`, rebuild OpenRGB with this controller added, and install the rebuilt OpenRGB binary as `/usr/local/bin/openrgb`.

```bash
sudo install -d -m 755 -o "$USER" -g "$(id -gn)" /usr/local/src/openrgb-asrock-steel-legend
cd /usr/local/src/openrgb-asrock-steel-legend

git clone https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git
cd openrgb-asrock-rx9070xt-steel-legend-controller

./install-native.sh
```

The installer does these actions:

```text
clones the tested OpenRGB source commit into /usr/local/src/openrgb-asrock-steel-legend/OpenRGB
copies this controller folder into OpenRGB/Controllers/
auto-detects the AMDGPU OEM I2C bus when possible
rebuilds OpenRGB
checks that the rebuilt binary contains the Steel Legend controller
copies the rebuilt binary to /usr/local/bin/openrgb
```

After it finishes, confirm the normal command runs the rebuilt copy:

```bash
command -v openrgb
```

Expected result:

```text
/usr/local/bin/openrgb
```

Then run OpenRGB normally:

```bash
openrgb
```

Expected result:

```text
OpenRGB opens
ASRock RX 9070 XT Steel Legend appears as a device
ARGB Header, Top / Side, and Fan appear as zones
```

## If the card is on a different I2C bus

The installer tries to find the AMDGPU OEM I2C bus automatically.

If the device does not appear, check the bus list:

```bash
i2cdetect -l
```

Look for the AMDGPU OEM bus. Example:

```text
i2c-7   i2c   AMDGPU DM i2c OEM bus   I2C adapter
```

Then rerun the installer with that bus number:

```bash
cd /usr/local/src/openrgb-asrock-steel-legend/openrgb-asrock-rx9070xt-steel-legend-controller
ASROCK_RX9070XT_I2C_BUS=7 ./install-native.sh
```

Replace `7` with the correct bus number from `i2cdetect -l`.

## Autostart

If OpenRGB is already set to start at login, set the autostart command to:

```text
/usr/local/bin/openrgb --startminimized
```

If you use a saved OpenRGB profile, add it after `--profile`.

Example:

```text
/usr/local/bin/openrgb --startminimized --profile "Dark"
```

## Remove this custom build

```bash
cd /usr/local/src/openrgb-asrock-steel-legend/openrgb-asrock-rx9070xt-steel-legend-controller
./uninstall-native.sh
```

That removes:

```text
/usr/local/bin/openrgb
/usr/local/src/openrgb-asrock-steel-legend
```

After that, the normal distro OpenRGB package should be used again:

```bash
command -v openrgb
openrgb --version
```

## Notes

This is hardware-mode support only. Direct per-frame LED streaming is not implemented.

The old standalone plugin test version should not be used at the same time as this native controller build.
