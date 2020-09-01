--虚拟大陆 每个玩家拥有一个
local skynet = require "skynet"
local util = require "util"
local json = require "cjson"
require "skynet.manager"

--大陆上的据点 （简化版城市）
local STRONGHOLD = {}
--大陆上的怪物
local MONSTER = {}

--数据持久化服务
local db_game
local db_guild

local arg = table.pack(...)
assert(arg.n == 1)
local player_id = tonumber(arg[1])

local player = {}
local stronghold = {}
local tavern = {}
local monster = {}
local PROP = {}
local EQUIP = {}

--指令集
local CMD = {}

--初始化虚拟大陆
function CMD.Init(player_data)
    skynet.error("初始化玩家", player_id, "的虚拟大陆")
    player = player_data
    stronghold = skynet.call(db_game, "lua", "LoadStrongholdList", player_id)
    tavern = skynet.call(db_game, "lua", "LoadTavernList", player_id)
    for k, v in pairs(tavern) do
        tavern[k].seat_0 = json.decode(v.seat_0)
        tavern[k].seat_1 = json.decode(v.seat_1)
        tavern[k].seat_2 = json.decode(v.seat_2)
        tavern[k].seat_3 = json.decode(v.seat_3)
        tavern[k].seat_4 = json.decode(v.seat_4)
    end
    monster = skynet.call(db_game, "lua", "LoadMonsterList", player_id)
    EQUIP = skynet.call(db_game, "lua", "LoadEquipList", player_id)
    PROP = skynet.call(db_game, "lua", "LoadPropList", player_id)
    return true
end

function CMD.GetTavern()
    skynet.error("返回酒馆数据")
    return tavern
end

function CMD.GetProp()
    skynet.error("返回道具数据")
    return PROP
end

function CMD.GetEquip()
    skynet.error("返回装备数据")
    return EQUIP
end

skynet.init(function()
    skynet.error("为玩家", player_id, "创建虚拟大陆")

    db_guild = skynet.queryservice("db_guild")
    db_game = skynet.queryservice("db_game")
end)

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        skynet.error("虚拟大陆服务 " .. player_id .. "收到" .. cmd .. "指令")
        if CMD[cmd] ~= nil then
            skynet.ret(skynet.pack(CMD[cmd](...)))
        else
            skynet.error("虚拟大陆服务没有定义 " .. cmd .. " 操作")
        end
    end)

    -- skynet.register("vland" .. player_id)
end)