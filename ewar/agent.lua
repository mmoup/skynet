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

local function send_package(pack)
	-- local package = string.pack(">s2", pack)
	socket.write(client_fd, pack)
end

local REQ = {}
function REQ.LoginAuthReq(message)
    for key,value in pairs(message) do
        skynet.error(key,":",value)
    end
end

local function dispatch_message(msg)
	skynet.error("msg", #msg)
	local msgid, msgBody = pbcoder.decode(msg)
	skynet.error(msgBody)
	for key,value in pairs(msgBody) do
        skynet.error(key,":",value)
	end
	if msgid == msgdef.message.LoginAuthReq then
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
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		skynet.error("msg length:", sz)
		return skynet.tostring(msg, sz)
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

	skynet.dispatch("client", function (session, address, msg)
        dispatch_message(msg)
    end)
end)
