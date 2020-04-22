-- =====================================================================================
--   Name:       proxy.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/proxy.lua
--   License:    The MIT License (MIT)
--
--   This submodule implements a wrapper for Dbus Proxies
-- =====================================================================================

-- Imports {{{
local lgi = require("lgi")
local Gio = lgi.require("Gio")

local DBusProxy = Gio.DBusProxy
local DBusNodeInfo = Gio.DBusNodeInfo
local DBusProxyFlags = Gio.DBusProxyFlags
local DBusCallFlags = Gio.DBusCallFlags
local DBusInterfaceInfo = Gio.DBusInterfaceInfo

local helpers = require("helpers")
-- }}}

-- -------------------------------------------------------------------------------------
-- Defining the Proxy Object

local Proxy = {}

-- -------------------------------------------------------------------------------------
-- Defining Local Functions

-- Generate proxy property {{{
local function attach_property(proxy, property)
    local prop = {}

    if property.flags.READABLE then
        prop.get = function()
            return proxy._proxy:get_cached_property(property.name)
        end

        prop.connect = function(callback)
            proxy:properties_changed(property.name, callback)
        end
    end

    if property.flags.WRITABLE then
        prop.set = function(args)
            proxy._proxy:set_cached_property(property.name, args)
        end
    end

    proxy[property.name] = prop
end
-- }}}

-- Generate proxy method {{{
local function attach_method(proxy, interface, method)
    local args = {}
    for _, arg in ipairs(method.in_args) do
        args[#args + 1] = {name = arg.name, type = arg.signature}
    end

    proxy._methods[method.name] = {args = args, interface = interface}

    proxy[method.name] = function(...)
        assert(
            #{...} == #args,
            string.format(
                "ERROR: " ..
                    interface ..
                        "." .. method.name .. " expects %d parameters but got %d",
                #args,
                #{...}
            )
        )

        for idx, val in ipairs({...}) do
            args[idx].value = val
        end

        return proxy:call(interface, method.name, helpers.pack_variant(args))
    end
end
-- }}}

-- Generate proxy signal {{{
local function attach_signal(proxy, signal)
    proxy[signal.name] = function(sender, callback)
        proxy._proxy.on_g_signal = function(_, sender_name, signal_name, args)
            if sender and sender_name ~= sender then
                return
            end

            if signal.name == signal_name then
                return callback(args)
            end
        end
    end
end
-- }}}

-- -------------------------------------------------------------------------------------
-- Adding Functions and Signals

-- Introspect {{{
function Proxy:introspect()
    return self:call("org.freedesktop.DBus.Introspectable", "Introspect")
end
-- }}}

-- Method call {{{
function Proxy:call(interface, method, args, timeout)
    return self._proxy:call_sync(
        interface .. "." .. method,
        args,
        DBusCallFlags.NONE,
        timeout or -1
    )
end
-- }}}

-- Properties signal {{{
function Proxy:properties_changed(property, callback)
    self._proxy.on_g_properties_changed = function(_, changed)
        if changed.value[property] ~= nil then
            local value = changed:get_child_value(0):get_child_value(1)
            return callback(value)
        end
    end
end
-- }}}

-- -------------------------------------------------------------------------------------
-- Adding Proxy Definition

-- Defining proxy {{{
function Proxy:new(bus, name, path, interface, flags)
    self._bus = bus
    self._path = path
    self._name = name
    self._methods = {}
    self._flags = flags
    self._interface = interface

    local proxy, err =
        DBusProxy.new_sync(
        self._bus,
        self._flags or DBusProxyFlags.NONE,
        DBusInterfaceInfo({name = self._interface}),
        self._name,
        self._path,
        self._interface
    )

    if err then
        error("There was an error in defining the proxy " .. name .. ". " .. err)
    end

    self._proxy = proxy

    local introspect_data
    introspect_data, err = self:introspect()

    if err then
        io.stderr:write("WARNING: Could not introspect " .. path .. " at " .. name)
        return
    end
    introspect_data = helpers.unpack_variant(introspect_data)

    local node = DBusNodeInfo.new_for_xml(introspect_data)

    for _, iface in ipairs(node.interfaces) do
        if iface.name == self._interface then
            for _, method in ipairs(iface.methods) do
                attach_method(self, iface.name, method)
            end

            for _, signal in ipairs(iface.signals) do
                attach_signal(self, signal)
            end

            for _, property in ipairs(iface.properties) do
                attach_property(self, property)
            end
        end
    end

    return self
end
-- }}}

-- -------------------------------------------------------------------------------------
return Proxy
