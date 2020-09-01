local skynet = require "skynet"
local util = require "util"

--玩家数据
local PLAYER = {}
local db_guild
local db_game
local land_id = 1

local CMD = {}

function CMD.Login(id)
    if PLAYER[id] ~= nil then
        PLAYER[id].is_online = "true"
        if PLAYER[id].service_addr == nil then
            --创建服务
            PLAYER[id].service_addr = skynet.newservice("vland", id)
            --初始化服务
            skynet.call(PLAYER[id].service_addr, "lua", "Init", PLAYER[id])
        end
        return true, PLAYER[id]
    end
    return false, "无此玩家"
end

skynet.init(function()
    skynet.error("启动玩家管理服务")

    db_guild = skynet.queryservice("db_guild")
    db_game = skynet.queryservice("db_game")

    local db_user_list = skynet.call(db_game, "lua", "LoadUserList", land_id)
    skynet.error("total users: ", #db_user_list)
    for key, db_user in pairs(db_user_list) do
        PLAYER[db_user.acct] = db_user
    end

    local db_player_list = skynet.call(db_guild, "lua", "LoadPlayerList", land_id)
    for key, db_player in pairs(db_player_list) do
        if PLAYER[db_player.id] ~= nil then
            for k, v in pairs(db_player) do
                PLAYER[db_player.id][k] = v
            end
        end
    end
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("玩家管理服务收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("玩家管理服务没有定义 " .. cmd .. " 操作")
        end
    end)
end)