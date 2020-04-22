--
--  ███       ███                      █████████           ███
--  ░██      ░░██                     ░░░░░░███           ░░██
--  ░██       ░██  █████ ███   █████       ███             ░██  █████ ███  █████
--  ░██████   ░██  ░███ ░██   ███░░██     ███      ████    ░██  ░███ ░██  ░░░░░██
--  ░███░░██  ░██  ░███ ░██  ░██████     ███      ░░░░     ░██  ░███ ░██   ██████
--  ░███░░██  ░██  ░███ ░██  ░███░░     ███                ░██  ░███ ░██  ███░░██
--  ░░█████   ████ ░███████  ░░██████  ████████            ████ ░███████  ░███████
--   ░░░░░   ░░░░  ░░░░░░░    ░░░░░░  ░░░░░░░░            ░░░░  ░░░░░░░   ░░░░░░░
--
-- =====================================================================================
--   Name:       init.lua
--   Author:     Gurpreet Singh
--   Url:        https://github.com/ffs97/bluez-dbus-lua/init.lua
--   License:    The MIT License (MIT)
--
--   This module implements a wrapper for the Bluez DBus API based on lgi. The classes
--   implemented are Manager, Adapter, and Device, each with helper functions to connect
--   to signals and easily read/write properties.
-- =====================================================================================

local helpers = require("helpers")

local Manager = require("manager")
local Adapter = require("adapter")
local Device = require("device")
local Proxy = require("proxy")

local get_system_bus = helpers.get_system_bus
local run_main_loop = helpers.run_main_loop

return {
    Manager = Manager,
    Adapter = Adapter,
    Device = Device,
    Proxy = Proxy,
    get_system_bus = get_system_bus,
    run_main_loop = run_main_loop
}
