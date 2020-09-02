local skynet = require "skynet"
local util = require "util"

local CITY = {}
local db_guild

local land_id = 1

local CMD = {}

function CMD.GetAllCity()
    skynet.error("返回城市数据")
    return CITY;
end

skynet.init(function()
    skynet.error("启动城市管理服务")

    db_guild = skynet.queryservice("db_guild")

    local db_city_list = skynet.call(db_guild, "lua", "LoadCityList", land_id)
    CITY = db_city_list;
    local vcity = db_city_list[1];
    vcity.conf = 60000000
    vcity.name = "虚拟城市"
    vcity.id = 10000
    vcity.kingdom_id = 100
    table.insert( CITY, vcity )
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