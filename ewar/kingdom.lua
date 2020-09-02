local skynet = require "skynet"
local util = require "util"

local KINGDOM = {}
local db_guild

local CMD = {}

function CMD.GetKingdom()
    return KINGDOM
end

skynet.init(function()
    skynet.error("启动王国管理服务")

    db_guild = skynet.queryservice("db_guild")

    local db_kingdom_list = skynet.call(db_guild, "lua", "LoadKingdomList")
    for key, db_kingdom in pairs(db_kingdom_list) do
        KINGDOM[db_kingdom.id] = db_kingdom
        --util.dump(db_kingdom)
    end
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("王国管理服务收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("王国管理服务没有定义 " .. cmd .. " 操作")
        end
    end)
end)