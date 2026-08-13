/*---------------------------------------------------------*\
| RGBController_ASRockRX9070XTGPU.cpp                       |
|                                                           |
|   RGBController for ASRock RX 9070 XT Steel Legend GPU    |
|                                                           |
|   This file is part of the OpenRGB project                |
|   SPDX-License-Identifier: GPL-2.0-or-later               |
\*---------------------------------------------------------*/

#include "RGBController_ASRockRX9070XTGPU.h"

#include <algorithm>
#include <cstdint>

namespace
{
    static constexpr unsigned int DEFAULT_SPEED      = 0x80;
    static constexpr unsigned int DEFAULT_BRIGHTNESS = 0xFF;
    static constexpr unsigned int DEFAULT_DIRECTION  = 0x00;

    uint8_t ClampToByte(unsigned int value)
    {
        return static_cast<uint8_t>(std::min(value, 255U));
    }

    uint8_t MapOpenRGBSpeedToHardwareSpeed(unsigned int value, unsigned int minimum, unsigned int maximum)
    {
        unsigned int clamped = std::min(std::max(value, minimum), maximum);
        return static_cast<uint8_t>((minimum + maximum) - clamped);
    }
}

/**------------------------------------------------------------------*\
    @name ASRock Radeon RX 9070 XT Steel Legend
    @category GPU
    @type I2C
    @save :x:
    @direct :x:
    @effects :white_check_mark:
    @detectors DetectASRockRX9070XTGPUControllers
    @comment
        Initial native controller for the ASRock Radeon RX 9070 XT
        Steel Legend GPU RGB controller.  This controller uses the
        known I2C packet at address 0x36 and exposes the three known
        hardware channels as OpenRGB zones.
\*-------------------------------------------------------------------*/

RGBController_ASRockRX9070XTGPU::RGBController_ASRockRX9070XTGPU(ASRockRX9070XTGPUController* controller_ptr)
    : controller(controller_ptr)
{
    name        = "ASRock RX 9070 XT Steel Legend";
    vendor      = "ASRock";
    description = "ASRock RX 9070 XT Steel Legend GPU RGB Controller";
    version     = "0.2.1-native";
    serial      = "";
    location    = controller ? controller->GetLocation() : "I2C bus unavailable";
    type        = DEVICE_TYPE_GPU;
    flags       = CONTROLLER_FLAG_LOCAL;

    AddHardwareMode("Off",                   0x01, MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_MODE_SPECIFIC);
    modes.back().colors[0] = ToRGBColor(0, 0, 0);

    AddHardwareMode("Static",                0x01, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Breathing",             0x02, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Strobe",                0x03, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("RGB Cycle",             0x04, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_NONE);
    AddHardwareMode("Random",                0x05, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS | MODE_FLAG_HAS_RANDOM_COLOR, MODE_COLORS_RANDOM);
    AddHardwareMode("Color Shift",           0x07, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_NONE);
    AddHardwareMode("Visor",                 0x08, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Stacking",              0x09, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Fill Wave",             0x0A, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Traveling Wave",        0x0B, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Marquee Color",         0x0C, MODE_FLAG_HAS_PER_LED_COLOR | MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_PER_LED);
    AddHardwareMode("Marquee Random",        0x0D, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS | MODE_FLAG_HAS_RANDOM_COLOR, MODE_COLORS_RANDOM);
    AddHardwareMode("Color Wave",            0x0E, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_NONE);
    AddHardwareMode("Rainbow",               0x0F, MODE_FLAG_HAS_SPEED | MODE_FLAG_HAS_BRIGHTNESS, MODE_COLORS_NONE);

    SetupZones();
}

RGBController_ASRockRX9070XTGPU::~RGBController_ASRockRX9070XTGPU()
{
    delete controller;
}

void RGBController_ASRockRX9070XTGPU::AddHardwareMode(const char* mode_name,
                                                      uint8_t value,
                                                      unsigned int mode_flags,
                                                      unsigned int color_mode)
{
    mode new_mode;
    new_mode.name           = mode_name;
    new_mode.value          = value;
    new_mode.flags          = mode_flags;
    new_mode.speed_min      = 0x20;
    new_mode.speed_max      = 0xFF;
    new_mode.speed          = DEFAULT_SPEED;
    new_mode.brightness_min = 0x20;
    new_mode.brightness_max = 0xFF;
    new_mode.brightness     = DEFAULT_BRIGHTNESS;
    new_mode.direction      = DEFAULT_DIRECTION;
    new_mode.color_mode     = color_mode;
    new_mode.colors_min     = 1;
    new_mode.colors_max     = 1;
    new_mode.colors.resize(1);
    new_mode.colors[0]      = ToRGBColor(255, 255, 255);

    modes.push_back(new_mode);
}

void RGBController_ASRockRX9070XTGPU::SetupZones()
{
    if(controller == nullptr)
    {
        return;
    }

    zones.clear();
    leds.clear();

    for(unsigned int channel_idx = 0; channel_idx < controller->GetChannelCount(); channel_idx++)
    {
        const auto& channel = controller->GetChannel(channel_idx);

        zone new_zone;
        new_zone.name       = channel.name;
        new_zone.type       = ZONE_TYPE_SINGLE;
        new_zone.leds_min   = 1;
        new_zone.leds_max   = 1;
        new_zone.leds_count = 1;
        new_zone.matrix_map = nullptr;
        new_zone.start_idx  = channel_idx;
        zones.push_back(new_zone);

        led new_led;
        new_led.name  = std::string(channel.name) + " LED";
        new_led.value = channel.value;
        leds.push_back(new_led);
    }

    SetupColors();

    for(unsigned int idx = 0; idx < colors.size(); idx++)
    {
        colors[idx] = ToRGBColor(255, 255, 255);
    }
}

void RGBController_ASRockRX9070XTGPU::ResizeZone(int /*zone*/, int /*new_size*/)
{
    // Fixed hardware zones.
}

void RGBController_ASRockRX9070XTGPU::DeviceUpdateLEDs()
{
    DeviceUpdateMode();
}

void RGBController_ASRockRX9070XTGPU::UpdateZoneLEDs(int zone)
{
    if(zone < 0 || static_cast<unsigned int>(zone) >= zones.size())
    {
        return;
    }

    if(controller == nullptr || active_mode < 0 || static_cast<unsigned int>(active_mode) >= modes.size())
    {
        return;
    }

    mode& current_mode = modes[active_mode];
    const auto& channel = controller->GetChannel(static_cast<unsigned int>(zone));
    RGBColor color = colors[zones[zone].start_idx];

    if(current_mode.color_mode == MODE_COLORS_MODE_SPECIFIC && !current_mode.colors.empty())
    {
        color = current_mode.colors[0];
    }

    controller->WriteChannel(channel.value,
                             ClampToByte(current_mode.value),
                             RGBGetRValue(color),
                             RGBGetGValue(color),
                             RGBGetBValue(color),
                             MapOpenRGBSpeedToHardwareSpeed(current_mode.speed, current_mode.speed_min, current_mode.speed_max),
                             ClampToByte(current_mode.brightness),
                             ClampToByte(current_mode.direction));
}

void RGBController_ASRockRX9070XTGPU::UpdateSingleLED(int led_idx)
{
    UpdateZoneLEDs(led_idx);
}

void RGBController_ASRockRX9070XTGPU::DeviceUpdateMode()
{
    for(unsigned int zone_idx = 0; zone_idx < zones.size(); zone_idx++)
    {
        UpdateZoneLEDs(static_cast<int>(zone_idx));
    }
}
