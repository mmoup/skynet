local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"	-- import skynet.register
local util = require "util"

local db
local CMD = {}

function CMD.UUID()
	return db:query("SELECT REPLACE(UUID(),\"-\", \"\") AS `uuid`")[1].uuid
end

--加载单个玩家资料
function CMD.LoadUser(player_id)
	skynet.error("player_id", player_id)
    local stmt = db:prepare("SELECT * FROM `user` AS u LEFT JOIN `totalinfo` AS ti ON ti.`acct`=u.`acct` LEFT JOIN `userotherinfo` AS uoi ON uoi.`acct`=u.`acct` WHERE u.`acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res[1]
end

--加载全部酒馆资料
function CMD.LoadTavernList(player_id)
    local stmt = db:prepare("SELECT * FROM `halltavern` AS ht WHERE ht.`acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载全部要塞资料
function CMD.LoadStrongholdList(player_id)
    local stmt = db:prepare("SELECT * FROM `pvecity` AS ht WHERE ht.`acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载全部怪物资料
function CMD.LoadMonsterList(player_id)
    local stmt = db:prepare("SELECT * FROM `pvemonster` WHERE `acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载全部装备资料
function CMD.LoadEquipList(player_id)
    local stmt = db:prepare("SELECT * FROM `equips` WHERE `acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载全部道具资料
function CMD.LoadPropList(player_id)
    local stmt = db:prepare("SELECT * FROM `items` WHERE `acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载商店物品资料
function CMD.LoadShopItemList(player_id)
    local stmt = db:prepare("SELECT * FROM `stall` WHERE `acct`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载全体玩家资料
function CMD.LoadUserList(land_id)
    local sql = [[
        SELECT * FROM `user` AS u
        LEFT JOIN `totalinfo` AS ti ON ti.`acct`=u.`acct`
        LEFT JOIN `userotherinfo` AS uoi ON uoi.`acct`=u.`acct`
        LEFT JOIN `hallmain` AS hm ON hm.`acct`=u.`acct`
        LEFT JOIN `halltrain` AS ht ON ht.`acct`=u.`acct`
        LEFT JOIN `stall` AS s ON s.`acct`=u.`acct`
        WHERE u.`server`=?
    ]]
    local stmt = db:prepare(sql)
	local res = db:execute(stmt, land_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--加载部队资料
function CMD.LoadUnitList(player_id)
    local sql = [[
        SELECT * FROM `troops` AS t
        WHERE t.`acct`=?
    ]]
    local stmt = db:prepare(sql)
	local res = db:execute(stmt, player_id)
    db:stmt_close(stmt)
    return res
end

--保存玩家资料
function CMD.SavePlayer(player_id, ...)
    local args = {...}
end

skynet.start(function()
    skynet.error("启动pve数据库服务")
    local function on_connect(db)
		skynet.error("db connected")
    end

    db = mysql.connect({
		host = "127.0.0.1",
		port = 3306,
		database = "ewar_game",
		charset = "utf8mb4",
		user = "dev",
		password = "vDVmqAF@FWkR%uw9",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})

	if not db then
		skynet.error("failed to connect mysql")
		skynet.exit()
	else
		skynet.error('success to connect to mysql')
	end

	skynet.dispatch("lua", function(session, address, cmd, ...)
		--cmd = cmd:upper()
		if cmd == "PING" then
			assert(session == 0)
			local str = (...)
			if #str > 20 then
				str = str:sub(1,20) .. "...(" .. #str .. ")"
			end
			skynet.error(string.format("%s ping %s", skynet.address(address), str))
			return
		end

        if CMD[cmd] ~= nil then
			skynet.ret(skynet.pack(CMD[cmd](...)))
		else
			skynet.error("pve数据库服务没有定义" .. cmd .. "操作")
		end
	end)
--	skynet.traceproto("lua", false)	-- true off tracelog
--	skynet.register ".db"
end)
