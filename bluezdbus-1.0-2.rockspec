package = "bluezdbus"
version = "1.0-2"
source = {
    url = "git+ssh://git@github.com/ffs97/bluezdbus-lua.git",
    tag = "v1.0"
}
description = {
    summary = "A wrapper for the BlueZ DBus API written in lua",
    detailed = [[
        The BluezDBus module implements a wrapper for the BlueZ DBus API based on lgi.
        The classes implemented are Manager, Adapter, and Device, each with helper
        function to connect to signals and easily read/write properties.
    ]],
    homepage = "https://www.github.com/ffs97/bluezdbus-lua",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1",
    "lgi >= 0.9.2"
}
build = {
    type = "builtin",
    modules = {
        ["bluezdbus"] = "src/init.lua",
        ["bluezdbus.adapter"] = "src/adapter.lua",
        ["bluezdbus.device"] = "src/device.lua",
        ["bluezdbus.helpers"] = "src/helpers.lua",
        ["bluezdbus.manager"] = "src/manager.lua",
        ["bluezdbus.proxy"] = "src/proxy.lua",
    }
}
