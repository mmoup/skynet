local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local util = require "util"
local json = require "cjson"
local sharetable = require "skynet.sharetable"

local max_client = 64

skynet.start(function()
	skynet.error("Server start")
    skynet.uniqueservice("protoloader")

	skynet.error("Begin loading config")
    sharetable.loadtable('activity', json.decode(util.file_load('./config/Activity.json')))
    sharetable.loadtable('anim', json.decode(util.file_load('./config/Anim.json')))
    sharetable.loadtable('building', json.decode(util.file_load('./config/Building.json')))
    sharetable.loadtable('city', json.decode(util.file_load('./config/City.json')))
    sharetable.loadtable('chest', json.decode(util.file_load('./config/Chest.json')))
    sharetable.loadtable('equip', json.decode(util.file_load('./config/Equip.json')))
    sharetable.loadtable('field', json.decode(util.file_load('./config/Field.json')))
    sharetable.loadtable('lang', json.decode(util.file_load('./config/Lang.json')))
    sharetable.loadtable('pays', json.decode(util.file_load('./config/Pays.json')))
    sharetable.loadtable('prop', json.decode(util.file_load('./config/Prop.json')))
    sharetable.loadtable('roboot', json.decode(util.file_load('./config/Roboot.json')))
    sharetable.loadtable('setup', json.decode(util.file_load('./config/Setup.json')))
    sharetable.loadtable('skill', json.decode(util.file_load('./config/Skill.json')))
    sharetable.loadtable('store', json.decode(util.file_load('./config/Store.json')))
    sharetable.loadtable('task', json.decode(util.file_load('./config/Task.json')))
    sharetable.loadtable('tour', json.decode(util.file_load('./config/Tour.json')))
    sharetable.loadtable('unit', json.decode(util.file_load('./config/Unit.json')))
    sharetable.loadtable('user', json.decode(util.file_load('./config/User.json')))
    sharetable.loadtable('wall', json.decode(util.file_load('./config/Wall.json')))
    sharetable.loadtable('wild', json.decode(util.file_load('./config/Wild.json')))
    skynet.error("Config loaded")

    --pve数据库服务
    skynet.uniqueservice("db_game")
    --pvp数据库服务
    skynet.uniqueservice("db_guild")
    --大陆管理服务
    skynet.uniqueservice("land")
    --城市管理服务
    skynet.uniqueservice("city")
    --王国管理服务
    skynet.uniqueservice("kingdom")
    --军团管理服务
    skynet.uniqueservice("troop")
    --战争管理服务
    skynet.uniqueservice("war")
    --玩家管理服务
    skynet.uniqueservice("player")

	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console", 8000)
	-- skynet.newservice("login_http")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
    skynet.error("Watchdog listen on", 8888)
    --执行完就退出
	skynet.exit()
end)
