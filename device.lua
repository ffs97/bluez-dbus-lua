-- =====================================================================================
--   Name:       device.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/device.lua
--   License:    The MIT License (MIT)
--
--   This submodule implements a wrapper for Bluez Device
-- =====================================================================================

local Proxy = require("proxy")

-- -------------------------------------------------------------------------------------
-- Adding Device Definition

local Device = {}

-- Defining manager {{{
function Device:new(bus, path)
    local name = "org.bluez"
    local iface = "org.bluez.Device1"

    local device = Proxy:new(bus, name, path, iface)

    setmetatable(device, self)
    self.__index = self

    return device
end
-- }}}

-- -------------------------------------------------------------------------------------
return Device
