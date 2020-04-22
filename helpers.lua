-- =====================================================================================
--   Name:       helpers.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/helpers.lua
--   License:    The MIT License (MIT)
--
--   This submodule defines helper functions and utilities for bluez-dbus-lua api
-- =====================================================================================

-- Imports {{{
local lgi = require("lgi")
local Gio = lgi.require("Gio")
local GLib = lgi.require("GLib")

local Variant = GLib.Variant
local VariantType = GLib.VariantType
-- }}}

-- Globals {{{
local simple_unpack_map = {
    b = "boolean",
    y = "byte",
    n = "int16",
    q = "uint16",
    i = "int32",
    u = "uint32",
    x = "int64",
    t = "uint64",
    d = "double",
    s = "string",
    o = "string",
    g = "string",
    v = "variant"
}

local helpers = {}
-- }}}

local clock = os.clock
function helpers.sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

-- -------------------------------------------------------------------------------------
-- Bus

-- System bus {{{
function helpers.get_system_bus()
    return Gio.bus_get_sync(Gio.BusType.SYSTEM)
end
-- }}}

-- Session bus {{{
function helpers.get_session_bus()
    return Gio.bus_get_sync(Gio.BusType.SESSION)
end
-- }}}

-- Run main loop {{
function helpers.run_main_loop()
    GLib.MainLoop():run()
end
-- }}

-- -------------------------------------------------------------------------------------
-- GLib Variants

-- Pack variants {{{
function helpers.pack_variant(...)
    if not ... then
        return nil
    end

    local sig = "("
    local val = {}
    for i, v in ipairs(...) do
        sig = sig .. v.type
        val[i] = v.value
    end
    sig = sig .. ")"
    return Variant(sig, val)
end
-- }}}

-- Unpack variants {{{
function helpers.unpack_variant(v)
    local vtype = v:get_type_string()
    local func = simple_unpack_map[vtype]

    local data

    if func then
        data = Variant["get_" .. func](v)

        if vtype == "v" then
            data = helpers.unpack_variant(data)
        end
    elseif vtype:match("^m") then
        data =
            (v:n_children() == 1 and helpers.unpack_variant(v:get_child_value(0)) or nil)
    elseif vtype:match("^[{(r]") then
        n = v:n_children()

        if n == 1 then
            data = helpers.unpack_variant(v:get_child_value(0))
        else
            data = {}
            for i = 1, n do
                data[i] = helpers.unpack_variant(v:get_child_value(i - 1))
            end
        end
    elseif Variant.is_of_type(v, VariantType.BYTESTRING) then
        data = tostring(v.data)
    elseif Variant.is_of_type(v, VariantType.DICTIONARY) then
        data = {}

        local entry, key, value
        for i = 0, Variant.n_children(v) - 1 do
            entry = Variant.get_child_value(v, i)

            key = helpers.unpack_variant(Variant.get_child_value(entry, 0))
            value = helpers.unpack_variant(Variant.get_child_value(entry, 1))

            data[key] = value
        end
    elseif vtype:match("^a") then
        data = {n = v:n_children()}
        for i = 1, data.n do
            data[i] = helpers.unpack_variant(v:get_child_value(i - 1))
        end
    end

    if data == nil then
        print(v:print(), data, vtype)
    end

    return data
end
-- }}}

-- -------------------------------------------------------------------------------------
return helpers
