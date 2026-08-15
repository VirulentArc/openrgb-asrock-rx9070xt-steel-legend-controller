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

namespace
{
    static constexpr uint16_t AMD_PCI_VENDOR_ID                         = 0x1002;
    static constexpr uint16_t AMD_NAVI48_RX9070XT_PCI_DEVICE_ID         = 0x7550;
    static constexpr uint16_t ASROCK_PCI_SUBSYSTEM_VENDOR_ID            = 0x1849;
    static constexpr uint16_t ASROCK_RX9070XT_STEEL_LEGEND_SUBDEVICE_ID = 0x5403;
    static constexpr uint8_t  ASROCK_RX9070XT_RGB_ADDRESS               = ASRockRX9070XTGPUController::I2C_ADDRESS;
}

void DetectASRockRX9070XTGPUControllers(i2c_smbus_interface* bus, uint8_t address, const std::string& name)
{
    if(bus == nullptr)
    {
        return;
    }

    ASRockRX9070XTGPUController* controller = new ASRockRX9070XTGPUController(bus, name);
    RGBController_ASRockRX9070XTGPU* rgb_controller = new RGBController_ASRockRX9070XTGPU(controller);

    LOG_INFO("[%s] Registering ASRock RX 9070 XT Steel Legend RGB controller on I2C bus %d address 0x%02X",
             name.c_str(), bus->bus_id, address);

    ResourceManager::get()->RegisterRGBController(rgb_controller);
}

REGISTER_I2C_PCI_DETECTOR("ASRock RX 9070 XT Steel Legend",
                          DetectASRockRX9070XTGPUControllers,
                          AMD_PCI_VENDOR_ID,
                          AMD_NAVI48_RX9070XT_PCI_DEVICE_ID,
                          ASROCK_PCI_SUBSYSTEM_VENDOR_ID,
                          ASROCK_RX9070XT_STEEL_LEGEND_SUBDEVICE_ID,
                          ASROCK_RX9070XT_RGB_ADDRESS);
