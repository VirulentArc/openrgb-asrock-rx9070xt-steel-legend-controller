# OpenRGB ASRock RX 9070 XT Steel Legend Controller

Native OpenRGB controller source for the ASRock Radeon RX 9070 XT Steel Legend GPU RGB controller.

## What this controller is

This repository contains one native OpenRGB controller folder for the ASRock Radeon RX 9070 XT Steel Legend.

A native OpenRGB controller is source code that gets compiled into OpenRGB. After this controller folder is added to an OpenRGB source checkout and OpenRGB is rebuilt, the card can appear as a normal OpenRGB device.

This controller talks to the GPU RGB controller over the AMDGPU OEM I2C bus at address `0x36`.

## Requirements

OpenRGB should already be installed and able to open normally.

Check that first:

```bash
openrgb --version
openrgb
```

You also need the normal tools required to build OpenRGB from source:

```text
git
qmake
make
C++ compiler
```

## Supported hardware

Tested card:

```text
ASRock Radeon RX 9070 XT Steel Legend 16GB
RGB I2C address: 0x36
Tested OpenRGB I2C bus: 7
```

Known hardware channels:

```text
3 = ARGB Header
6 = Top / Side
7 = Fan
```

This release uses the tested Linux OpenRGB I2C bus detector. It registers the controller on bus `7` at address `0x36`.

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

## Step 1: create the build workspace

This creates a clean source/build workspace under `/usr/local/src`.

```bash
sudo rm -rf /usr/local/src/openrgb-asrock-steel-legend
sudo mkdir -p /usr/local/src/openrgb-asrock-steel-legend
sudo chown "$USER" /usr/local/src/openrgb-asrock-steel-legend
cd /usr/local/src/openrgb-asrock-steel-legend
```

## Step 2: get the tested OpenRGB source code

This downloads the OpenRGB source code into the build workspace and checks out the OpenRGB commit this controller was tested with.

```bash
git clone https://gitlab.com/CalcProgrammer1/OpenRGB.git
cd /usr/local/src/openrgb-asrock-steel-legend/OpenRGB
git checkout 4306603a28c86e91f4dd4f89b41efd3005f0b810
```

Confirm the checked-out commit:

```bash
git rev-parse HEAD
```

Expected result:

```text
4306603a28c86e91f4dd4f89b41efd3005f0b810
```

## Step 3: get this Steel Legend controller source

This downloads this controller repository into the same build workspace.

```bash
cd /usr/local/src/openrgb-asrock-steel-legend
git clone https://github.com/VirulentArc/openrgb-asrock-rx9070xt-steel-legend-controller.git
```

## Step 4: copy the controller into the OpenRGB source tree

This places the Steel Legend controller folder inside OpenRGB's `Controllers/` folder.

```bash
rm -rf /usr/local/src/openrgb-asrock-steel-legend/OpenRGB/Controllers/ASRockRX9070XTGPUController
cp -a /usr/local/src/openrgb-asrock-steel-legend/openrgb-asrock-rx9070xt-steel-legend-controller/Controllers/ASRockRX9070XTGPUController \
      /usr/local/src/openrgb-asrock-steel-legend/OpenRGB/Controllers/
```

OpenRGB's qmake project automatically includes controller source files from the `Controllers/` folder. No manual `OpenRGB.pro` edit is needed.

## Step 5: rebuild OpenRGB

This builds OpenRGB from the source tree that now contains the Steel Legend controller.

```bash
cd /usr/local/src/openrgb-asrock-steel-legend/OpenRGB
rm -f OpenRGB openrgb Makefile .qmake.stash
qmake OpenRGB.pro
make -j4
```

The rebuilt binary should be:

```text
/usr/local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB
```

## Step 6: confirm the rebuilt binary contains the controller

This checks that the Steel Legend controller text exists inside the binary that was just built.

```bash
strings /usr/local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB | grep -F "ASRock RX 9070 XT Steel Legend"
```

Expected result:

```text
ASRock RX 9070 XT Steel Legend
```

## Step 7: install the rebuilt OpenRGB binary as the normal command

This copies the rebuilt OpenRGB binary to `/usr/local/bin/openrgb`.

Most Linux systems check `/usr/local/bin` before `/usr/bin`, so the normal `openrgb` command should run this rebuilt copy.

```bash
sudo cp /usr/local/src/openrgb-asrock-steel-legend/OpenRGB/OpenRGB /usr/local/bin/openrgb
sudo chmod 755 /usr/local/bin/openrgb
```

Confirm which OpenRGB will run:

```bash
command -v openrgb
strings "$(command -v openrgb)" | grep -F "ASRock RX 9070 XT Steel Legend"
```

Expected command path:

```text
/usr/local/bin/openrgb
```

Expected controller text:

```text
ASRock RX 9070 XT Steel Legend
```

## Step 8: run OpenRGB normally

```bash
openrgb
```

Expected result:

```text
OpenRGB opens
ASRock RX 9070 XT Steel Legend appears as a device
ARGB Header, Top / Side, and Fan appear as zones
```

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

## If the device does not appear

First confirm that the OpenRGB binary being launched contains the controller:

```bash
command -v openrgb
strings "$(command -v openrgb)" | grep -F "ASRock RX 9070 XT Steel Legend"
```

If the text does not appear, the normal `openrgb` command is not running the rebuilt binary.

If the text appears but the device still does not appear, check the I2C bus list:

```bash
i2cdetect -l
```

This release expects the tested Steel Legend RGB bus to be OpenRGB I2C bus `7`. If the AMDGPU OEM bus is not bus `7` on your system, edit this line before rebuilding:

```cpp
static constexpr int     ASROCK_RX9070XT_TESTED_BUS_ID = 7;
```

File:

```text
/usr/local/src/openrgb-asrock-steel-legend/OpenRGB/Controllers/ASRockRX9070XTGPUController/ASRockRX9070XTGPUControllerDetect.cpp
```

Change `7` to the correct AMDGPU OEM I2C bus number, then rebuild from Step 5.

## Remove this custom build

This removes the rebuilt OpenRGB binary and the source/build workspace.

```bash
sudo rm -f /usr/local/bin/openrgb
sudo rm -rf /usr/local/src/openrgb-asrock-steel-legend
```

After that, the normal distro OpenRGB package should be used again:

```bash
command -v openrgb
openrgb --version
```

## Notes

This is hardware-mode support only. Direct per-frame LED streaming is not implemented.

The old standalone plugin test version should not be used at the same time as this native controller build.
