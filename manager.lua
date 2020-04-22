-- =====================================================================================
--   Name:       manager.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/manager.lua
--   License:    The MIT License (MIT)
--
--   This submodule implements a wrapper for Bluez ObjectManager
-- =====================================================================================

local Proxy = require("proxy")
local helpers = require("helpers")

-- -------------------------------------------------------------------------------------
-- Adding Manager Definition

local Manager = {}

-- Adding functions {{{
function Manager.get_adapters(manager)
    local objects = helpers.unpack_variant(manager.GetManagedObjects())
    local adapters = {}

    for path, _ in pairs(objects) do
        if path:match("/org/bluez/hci[0-9]+$") then
            adapters[#adapters + 1] = path
        end
    end

    return adapters
end

function Manager.get_active_adapter(manager)
    local objects = helpers.unpack_variant(manager.GetManagedObjects())

    local adapter
    for path, _ in pairs(objects) do
        if path:match("/org/bluez/hci[0-9]+$") then
            adapter = path
            if objects[adapter].Powered then
                break
            end
        end
    end

    return adapter
end
-- }}}

-- Defining manager {{{
function Manager:new(bus)
    local path = "/"
    local name = "org.bluez"
    local iface = "org.freedesktop.DBus.ObjectManager"

    local manager = Proxy:new(bus, name, path, iface)

    setmetatable(manager, self)
    self.__index = self

    return manager
end
-- }}}

-- -------------------------------------------------------------------------------------
return Manager
