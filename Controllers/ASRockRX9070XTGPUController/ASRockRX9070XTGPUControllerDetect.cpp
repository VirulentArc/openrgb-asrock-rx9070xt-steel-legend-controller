/*---------------------------------------------------------*\
| ASRockRX9070XTGPUControllerDetect.cpp                     |
|                                                           |
|   Detector for ASRock RX 9070 XT Steel Legend GPU RGB     |
|                                                           |
|   This file is part of the OpenRGB project                |
|   SPDX-License-Identifier: GPL-2.0-or-later               |
\*---------------------------------------------------------*/

#include "Detector.h"
#include "LogManager.h"
#include "ResourceManager.h"
#include "ASRockRX9070XTGPUController.h"
#include "RGBController_ASRockRX9070XTGPU.h"
#include "i2c_smbus.h"

#include <cstdint>
#include <string>
#include <vector>

namespace
{
    static constexpr uint8_t ASROCK_RX9070XT_RGB_ADDRESS = ASRockRX9070XTGPUController::I2C_ADDRESS;
    static constexpr int     ASROCK_RX9070XT_TESTED_BUS_ID = 7;
}

void DetectASRockRX9070XTGPUControllers(std::vector<i2c_smbus_interface*>& busses)
{
    for(i2c_smbus_interface* bus : busses)
    {
        if(bus == nullptr)
        {
            continue;
        }

        if(bus->bus_id != ASROCK_RX9070XT_TESTED_BUS_ID)
        {
            continue;
        }

        const std::string name = "ASRock RX 9070 XT Steel Legend";

        ASRockRX9070XTGPUController* controller = new ASRockRX9070XTGPUController(bus, name);
        RGBController_ASRockRX9070XTGPU* rgb_controller = new RGBController_ASRockRX9070XTGPU(controller);

        LOG_INFO("[%s] Registering ASRock RX 9070 XT Steel Legend RGB controller on I2C bus %d address 0x%02X",
                 name.c_str(), bus->bus_id, ASROCK_RX9070XT_RGB_ADDRESS);

        ResourceManager::get()->RegisterRGBController(rgb_controller);
        return;
    }
}

REGISTER_I2C_DETECTOR("ASRock RX 9070 XT Steel Legend", DetectASRockRX9070XTGPUControllers);
