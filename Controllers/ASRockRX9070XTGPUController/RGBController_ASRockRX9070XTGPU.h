/*---------------------------------------------------------*\
| RGBController_ASRockRX9070XTGPU.h                         |
|                                                           |
|   RGBController for ASRock RX 9070 XT Steel Legend GPU    |
|                                                           |
|   This file is part of the OpenRGB project                |
|   SPDX-License-Identifier: GPL-2.0-or-later               |
\*---------------------------------------------------------*/

#pragma once

#include <cstdint>

#include "RGBController.h"
#include "ASRockRX9070XTGPUController.h"

class RGBController_ASRockRX9070XTGPU : public RGBController
{
public:
    explicit RGBController_ASRockRX9070XTGPU(ASRockRX9070XTGPUController* controller_ptr);
    ~RGBController_ASRockRX9070XTGPU() override;

    void SetupZones() override;
    void ResizeZone(int zone, int new_size) override;
    void DeviceUpdateLEDs() override;
    void UpdateZoneLEDs(int zone) override;
    void UpdateSingleLED(int led) override;
    void DeviceUpdateMode() override;

private:
    ASRockRX9070XTGPUController* controller;

    void AddHardwareMode(const char* name,
                         uint8_t value,
                         unsigned int flags,
                         unsigned int color_mode);
};
