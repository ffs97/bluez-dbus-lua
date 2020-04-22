-- =====================================================================================
--   Name:       adapter.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/adapter.lua
--   License:    The MIT License (MIT)
--
--   This submodule implements a wrapper for Bluez Adapter
-- =====================================================================================

local Proxy = require("proxy")
local helpers = require("helpers")

local DBusNodeInfo = require("lgi").Gio.DBusNodeInfo

-- -------------------------------------------------------------------------------------
-- Adding Adapter Definition

local Adapter = {}

-- Adding functions {{{
function Adapter.get_devices(adapter)
    local introspect_data, err = adapter:introspect()

    if err then
        error("ERROR: Could not introspect " .. adapter._path .. " at " .. adapter._name)
        return
    end
    introspect_data = helpers.unpack_variant(introspect_data)

    local node = DBusNodeInfo.new_for_xml(introspect_data)

    local devices = {}
    for _, device in ipairs(node.nodes) do
        devices[#devices + 1] = adapter._path .. "/" .. device.path
    end

    return devices
end
-- }}}

-- Defining manager {{{
function Adapter:new(bus, path)
    local name = "org.bluez"
    local iface = "org.bluez.Adapter1"

    local adapter = Proxy:new(bus, name, path, iface)

    setmetatable(adapter, self)
    self.__index = self

    return adapter
end
-- }}}

-- -------------------------------------------------------------------------------------
return Adapter
