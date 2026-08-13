/*---------------------------------------------------------*\
| ASRockRX9070XTGPUController.h                             |
|                                                           |
|   Driver for ASRock RX 9070 XT Steel Legend GPU RGB       |
|                                                           |
|   This file is part of the OpenRGB project                |
|   SPDX-License-Identifier: GPL-2.0-or-later               |
\*---------------------------------------------------------*/

#pragma once

#include <cstdint>
#include <string>
#include <vector>

#include "i2c_smbus.h"

class ASRockRX9070XTGPUController
{
public:
    static constexpr uint8_t I2C_ADDRESS = 0x36;

    struct Channel
    {
        const char* name;
        uint8_t     value;
    };

    explicit ASRockRX9070XTGPUController(i2c_smbus_interface* bus_ptr, std::string device_name);

    std::string GetName() const;
    std::string GetLocation() const;
    unsigned int GetChannelCount() const;
    const Channel& GetChannel(unsigned int index) const;

    bool WriteChannel(uint8_t channel,
                      uint8_t mode,
                      uint8_t red,
                      uint8_t green,
                      uint8_t blue,
                      uint8_t speed,
                      uint8_t brightness,
                      uint8_t direction);

private:
    i2c_smbus_interface* bus;
    std::string          name;
    std::vector<Channel> channels;
};
