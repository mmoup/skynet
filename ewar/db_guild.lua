local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"	-- import skynet.register
local util = require "util"
local db
local command = {}

function command.UUID()
	return db:query("SELECT REPLACE(UUID(),\"-\", \"\") AS `uuid`")[1].uuid
end

--加载玩家资料
function command.LoadPlayer(player_id)
	skynet.error("player_id", player_id)
    local stmt = db:prepare("SELECT * FROM `player` WHERE `id`=?")
	local res = db:execute(stmt, player_id)
--	print("query result=", util.dump(res))
    db:stmt_close(stmt)
    return res[1]
end

--保存玩家资料
function command.SavePlayer(player_id, ...)
    local args = {...}
end

skynet.start(function()
    skynet.error("启动mysql服务")
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
        local f = command[cmd]
        skynet.error(f)
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
--	skynet.traceproto("lua", false)	-- true off tracelog
--	skynet.register ".db"
end)
