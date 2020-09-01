local skynet = require "skynet"
local util = require "util"

local TROOP = {}
local db_guild

local CMD = {}

function CMD.attack()
end

skynet.init(function()
    skynet.error("启动军团管理服务")

    db_guild = skynet.queryservice("db_guild")

    local db_troop_list = skynet.call(db_guild, "lua", "LoadTroopList")
    for key, db_troop in pairs(db_troop_list) do
        TROOP[db_troop.id] = db_troop
        --util.dump(db_troop)
    end
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("军团管理服务收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("军团管理服务没有定义 " .. cmd .. " 操作")
        end
    end)
end)