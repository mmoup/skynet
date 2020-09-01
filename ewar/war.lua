local skynet = require "skynet"
local util = require "util"

local db_guild

local WAR = {}
local CMD = {}

function CMD.attack()
end

skynet.init(function()
    skynet.error("启动战争管理服务")

    db_guild = skynet.queryservice("db_guild")

    local db_war_list = skynet.call(db_guild, "lua", "LoadWarList")
    for key, db_war in pairs(db_war_list) do
        WAR[db_war.id] = db_war
        --util.dump(db_war)
    end
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("战争管理服务收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("战争管理服务没有定义 " .. cmd .. " 操作")
        end
    end)
end)