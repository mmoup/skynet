local skynet = require "skynet"
local socket = require "skynet.socket"
local mysql = require "skynet.db.mysql"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local util = require "util"
local json = require "cjson"
local table = table
local string = string

local mode, protocol = ...
protocol = protocol or "http"

if mode == "agent" then

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end


local SSLCTX_SERVER = nil
local function gen_interface(protocol, fd)
	if protocol == "http" then
		return {
			init = nil,
			close = nil,
			read = sockethelper.readfunc(fd),
			write = sockethelper.writefunc(fd),
		}
	elseif protocol == "https" then
		local tls = require "http.tlshelper"
		if not SSLCTX_SERVER then
			SSLCTX_SERVER = tls.newctx()
			-- gen cert and key
			-- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
			local certfile = skynet.getenv("certfile") or "./server-cert.pem"
			local keyfile = skynet.getenv("keyfile") or "./server-key.pem"
			print(certfile, keyfile)
			SSLCTX_SERVER:set_cert(certfile, keyfile)
		end
		local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
		return {
			init = tls.init_responsefunc(fd, tls_ctx),
			close = tls.closefunc(tls_ctx),
			read = tls.readfunc(fd, tls_ctx),
			write = tls.writefunc(fd, tls_ctx),
		}
	else
		error(string.format("Invalid protocol: %s", protocol))
	end
end


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


skynet.start(function()
	skynet.uniqueservice("db_web")

	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		local interface = gen_interface(protocol, id)
		if interface.init then
			interface.init()
		end
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(interface.read, 8192)
		if code then
			if code ~= 200 then
				response(id, interface.write, code)
			else
				local path, querystring = urllib.parse(url)
				local query = {}
				if querystring then
					query = urllib.parse_query(querystring)
					print(util.serialise_value(query))
				end
				if path == '/device/login' then
					if query.device_id ~= nil then
						local db_user, token = skynet.call(skynet.queryservice("db_web"), "lua", "FindUser", query.device_id)
						if db_user ~= nil then
							local resp = {
								code = 200,
								message = "success",
								user_id = db_user.id,
								device_id = query.device_id,
								token = token,
								servers = {"127.0.0.1:8888"},
								bind_game_center = false,
								bind_google = false,
								bind_facebook = false
							}
							response(id, interface.write, 200, json.encode(resp))
						else
							response(id, interface.write, 400, 'the device is not registered')
						end
					else
						response(id, interface.write, 400, 'device_id is required')
					end
				elseif path == '/check' then
					local resp = {
						code = 200,
						message = "OK",
					}
					response(id, interface.write, code, json.encode(resp))
				elseif path == '/info' then
					if query.token ~= nil then
						local user_id = skynet.call(skynet.queryservice("db_web"), "lua", "Info", query.token)
						if user_id ~= nil then
							local resp = {
								code = 200,
								message = "success",
								user_id = user_id,
							}
							response(id, interface.write, code, json.encode(resp))
						else
							response(id, interface.write, 400, 'invalid token')
						end
					else
						response(id, interface.write, 400, 'token is required')
					end
                else
                    skynet.error(path)
                    response(id, interface.write, 404, 'Not found')
                end
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
		if interface.close then
			interface.close()
		end
	end)
end)

else

skynet.start(function()
	local agent = {}
	local protocol = "http"
	for i= 1, 2 do
		agent[i] = skynet.newservice(SERVICE_NAME, "agent", protocol)
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", 5000)
	skynet.error(string.format("Listen web port 8001 protocol:%s", protocol))
	socket.start(id , function(id, addr)
		skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
		skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)

end