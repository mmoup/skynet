local skynet = require "skynet"
local socket = require "skynet.socket"
local mysql = require "skynet.db.mysql"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
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
	local function on_connect(db)
		skynet.error("db connected")
	end

	local db = mysql.connect({
		host = "127.0.0.1",
		port = 3306,
		database = "ewar_web",
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
                local loginRespJson = [[
                    {
                        "code": 200,
                        "message": "OK",
                        "device_id": "e7001d97064ee1aeb95cee2a8aec80a3_2020-08-05-18_10_56",
                        "token": "5f3e21105877e",
                        "servers": ["127.0.0.1:8888"],
                        "bind_game_center": false,
                        "bind_google": false,
                        "bind_facebook": false
                    }
                ]]
                local patchRespJson = [[
                    {
                        "code": 200,
                        "message": "OK"
                    }
				]]
				local infoRespJson = [[
                    {
                        "code": 200,
						"message": "OK",
						"user_id": 100002
                    }
				]]

                local path, query = urllib.parse(url)
                if path == '/device/login' then
                    response(id, interface.write, code, loginRespJson)
                elseif path == '/check' then
					response(id, interface.write, code, patchRespJson)
				elseif path == '/info' then
					response(id, interface.write, code, infoRespJson)
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