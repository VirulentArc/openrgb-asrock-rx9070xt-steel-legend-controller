/*---------------------------------------------------------*\
| ASRockRX9070XTGPUController.cpp                           |
|                                                           |
|   Driver for ASRock RX 9070 XT Steel Legend GPU RGB       |
|                                                           |
|   This file is part of the OpenRGB project                |
|   SPDX-License-Identifier: GPL-2.0-or-later               |
\*---------------------------------------------------------*/

#include "ASRockRX9070XTGPUController.h"

#include <cstdio>
#include <utility>

ASRockRX9070XTGPUController::ASRockRX9070XTGPUController(i2c_smbus_interface* bus_ptr, std::string device_name)
    : bus(bus_ptr),
      name(std::move(device_name))
{
    channels.push_back({ "ARGB Header", 0x03 });
    channels.push_back({ "Top / Side",   0x06 });
    channels.push_back({ "Fan",          0x07 });
}

std::string ASRockRX9070XTGPUController::GetName() const
{
    return name;
}

std::string ASRockRX9070XTGPUController::GetLocation() const
{
    if(bus == nullptr)
    {
        return "I2C: unavailable";
    }

    char address_text[8];
    std::snprintf(address_text, sizeof(address_text), "0x%02X", I2C_ADDRESS);

    return std::string("I2C bus ") + std::to_string(bus->bus_id) +
           " addr " + address_text;
}

unsigned int ASRockRX9070XTGPUController::GetChannelCount() const
{
    return static_cast<unsigned int>(channels.size());
}

const ASRockRX9070XTGPUController::Channel& ASRockRX9070XTGPUController::GetChannel(unsigned int index) const
{
    return channels[index];
}

bool ASRockRX9070XTGPUController::WriteChannel(uint8_t channel,
                                               uint8_t mode,
                                               uint8_t red,
                                               uint8_t green,
                                               uint8_t blue,
                                               uint8_t speed,
                                               uint8_t brightness,
                                               uint8_t direction)
{
    if(bus == nullptr)
    {
        return false;
    }

    uint8_t packet[12] =
    {
        0x10, 0x00, channel,
        mode, red, green, blue,
        speed, brightness, direction,
        0x1A, 0x00
    };

    return bus->i2c_write_block(I2C_ADDRESS, sizeof(packet), packet) >= 0;
}
