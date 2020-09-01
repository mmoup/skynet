local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"	-- import skynet.register
local util = require "util"
local db
local CMD = {}

function CMD.UUID()
	return db:query("SELECT REPLACE(UUID(),\"-\", \"\") AS `uuid`")[1].uuid
end

--加载玩家资料
function CMD.LoadPlayer(player_id)
	skynet.error("player_id", player_id)
    local stmt = db:prepare("SELECT * FROM `player` WHERE `id`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res[1]
end

--加载城市
function CMD.LoadCityList(land_id)
	local city_list = db:query("SELECT * FROM `city` WHERE `land_id`=" .. land_id)
	return city_list
end

--加载王国
function CMD.LoadKingdomList()
	local kingdom_list = db:query("SELECT * FROM `kingdom`")
	return kingdom_list
end

--加载军团
function CMD.LoadTroopList()
	local troop_list = db:query("SELECT * FROM `troop`")
	return troop_list
end

--加载运输队
function CMD.LoadTransportList()
	local transport_list = db:query("SELECT * FROM `transport`")
	return transport_list
end

--加载战争
function CMD.LoadWarList()
	local war_list = db:query("SELECT * FROM `war`")
	return war_list
end

--加载全体玩家资料
function CMD.LoadPlayerList(land_id)
    local stmt = db:prepare("SELECT * FROM `player` WHERE `land_id`=?")
	local res = db:execute(stmt, land_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res
end

--保存玩家资料
function CMD.SavePlayer(player_id, ...)
    local args = {...}
end

skynet.start(function()
    skynet.error("启动pvp数据库服务")
    local function on_connect(db)
		skynet.error("db connected")
    end

    db = mysql.connect({
		host = "127.0.0.1",
		port = 3306,
		database = "ewar_guild",
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
			skynet.error("pvp数据库服务没有定义" .. cmd .. "操作")
		end
	end)
--	skynet.traceproto("lua", false)	-- true off tracelog
--	skynet.register ".db"
end)
