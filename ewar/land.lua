local skynet = require "skynet"

local land = {}

skynet.start(function()
    skynet.error("启动大陆管理服务")

    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("大陆管理服务收到" .. cmd .. "指令")
    end)
end)