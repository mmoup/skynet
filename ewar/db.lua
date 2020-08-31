local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
require "skynet.manager"	-- import skynet.register
local db = {}

local command = {}

local function dump(res, tab)
    tab = tab or 0
    if(tab == 0) then
        skynet.error("............dump...........")
	end

    if type(res) == "table" then
        skynet.error(string.rep("\t", tab).."{")
        for k,v in pairs(res) do
            if type(v) == "table" then
                dump(v, tab + 1)
            else
                skynet.error(string.rep("\t", tab), k, "=", v, ",")
            end
        end
        skynet.error(string.rep("\t", tab).."}")
    else
        skynet.error(string.rep("\t", tab) , res)
    end
end

function command.UUID()
	return db:query("SELECT REPLACE(UUID(),\"-\", \"\") AS `uuid`")[1].uuid
end

function command.FindUser(device_id)
	return db:query("SELECT * FROM user REPLACE(UUID(),\"-\", \"\") AS `uuid`")[1].uuid
end

function command.GET(key)
	return db[key]
end

function command.SET(key, value)
	local last = db[key]
	db[key] = value
	return last
end

--加载玩家资料
function command.LoadPlayer(player_id)
    local sql = "SELECT * FROM `player` WHERE id=" .. player_id
    skynet.error(sql)
    local res = db:query(sql)
    dump(res)
    return res
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
		database = "ewar_game",
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

	local res = db:query('set charset utf8mb4')
	dump(res)
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
