local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local pbcoder = require "protobufcoder"
local msgdef = require "protobufmsgdef"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

--[[
function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end
]]

local function send_package(pack)
	-- local package = string.pack(">s2", pack) 将长度自动补在最前面
	socket.write(client_fd, pack)
end

REQUEST.message = {}

function REQUEST.message.LoginAuthReq(msg_obj)
	for key,value in pairs(msg_obj) do
        skynet.error(key, ":", value)
	end
	local data = pbcoder.encode(msgdef.message.LoginAuthResp,
	{
		code = "SUCCEED",
		acct = {
			user = {
				acct = 10000,
				expss = 1,
				level = 1,
				land_id = 1,
				kingdom_id = -1,
				city_id = 0,
				name = "test",
				icon = "",
				flag = "",
			}
		}
	})
	send_package(data)
end

function REQUEST.message.LoginPingReq(msg_obj)
	for key,value in pairs(msg_obj) do
        skynet.error(key, ":", value)
	end

	local data = pbcoder.encode(msgdef.message.LoginPingResp,
	{
		code = "SUCCEED"
	})
	send_package(data)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		skynet.error("msg length:", sz)
		return skynet.tostring(msg, sz)
	end,
	dispatch = function (_, _, msg)
		local _, msg_name, msg_obj = pbcoder.decode(msg)
		local rt= {}
		string.gsub(msg_name, '[^.]+', function(w) table.insert(rt, w) end )
		local f = assert(REQUEST[rt[1]][rt[2]])
		local r = f(msg_obj)
	end
}

--[[
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch(msg, sz)
	end,
	dispatch = function (fd, _, type, ...)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		skynet.trace()
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}
]]

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, command, ...)
		skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
