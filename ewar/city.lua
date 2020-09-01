local skynet = require "skynet"
local util = require "util"

local CITY = {}
local db_guild

local CMD = {}

function CMD.attack()
end

skynet.init(function()
    skynet.error("启动城市管理服务")

    db_guild = skynet.queryservice("db_guild")

    local db_city_list = skynet.call(db_guild, "lua", "LoadCityList")
    for key, db_city in pairs(db_city_list) do
        CITY[db_city.id] = db_city
        --util.dump(db_city)
    end
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("城市管理服务收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("城市管理服务没有定义 " .. cmd .. " 操作")
        end
    end)
end)