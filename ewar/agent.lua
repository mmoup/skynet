local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local pbcoder = require "protobufcoder"
local msgdef = require "protobufmsgdef"
local sharetable = require "skynet.sharetable"
local util = require "util"
local httpc = require "http.httpc"
local dns = require "skynet.dns"
local json = require "cjson"

local WATCHDOG
local host
local send_request
local lastMsgId = 0

local CMD = {}
local REQUEST = {}

-- 网络接口
local client_fd
-- 虚拟服务
local player_service_addr

local function send_package(pack)
	-- local package = string.pack(">s2", pack) 将长度自动补在最前面
	socket.write(client_fd, pack)
end

REQUEST.message = {}

function REQUEST.message.LoginAuthReq(msg_obj)
	local respheader = {}
	local status, resp_body = httpc.request("GET", "127.0.0.1:5000", "/info?token=" .. msg_obj.token, respheader, {})
	skynet.error(resp_body)
	local result = json.decode(resp_body)
	util.dump(result)
	local player_id = result.user_id

	local ok, player = skynet.call(service_player, "lua", "Login", player_id)
	player_service_addr = player.service_addr

	--获取酒馆数据
	local tavern = skynet.call(player.service_addr, "lua", "GetTavern")
	local tavern_data = {}
	for k, v in pairs(tavern) do
		table.insert( tavern_data, {
			field_id = v.feild_city_id,
			seats = {
				{ indx = v.seat_0.Id, hero_conf = v.seat_0.HeroId, hero_time = v.seat_0.StayT },
				{ indx = v.seat_1.Id, hero_conf = v.seat_1.HeroId, hero_time = v.seat_1.StayT },
				{ indx = v.seat_2.Id, hero_conf = v.seat_2.HeroId, hero_time = v.seat_2.StayT },
				{ indx = v.seat_3.Id, hero_conf = v.seat_3.HeroId, hero_time = v.seat_3.StayT },
				{ indx = v.seat_4.Id, hero_conf = v.seat_4.HeroId, hero_time = v.seat_4.StayT },
			}
		} )
	end
	local equip = skynet.call(player.service_addr, "lua", "GetEquip")
	local equip_data = {}
	for k, v in pairs(equip) do
		table.insert( equip_data, { conf = v.item_id, num = v.sum_num } )
	end

	local porp = skynet.call(player.service_addr, "lua", "GetProp")
	local porp_data = {}
	for k, v in pairs(porp) do
		table.insert( porp_data, { conf = v.id, num = v.num } )
	end

	if ok then
		local resp_data = {
			code = "SUCCEED",
			acct = {
				user = {
					acct = player.acct,
					name = player.name,
					icon = player.icon,
					flag = player.flag,
					expss = player.exp,
					level = player.level,
					land_id = player.server,
					kingdom_id = player.kingdom_id,
					city_id = player.city_id,
					current_field_conf = player.stay_city_conf,
					from_field_conf = 0,
					remaining_time = 0,
					is_online = player.online == "true",
					is_giveme = true,
					is_recvme = true,
					coins = player.coins,
					feeds = player.feeds,
					jewel = player.jewel,

					cd_join_city = 0,
					cd_join_kingdom = 0,
					cd_city_build = 0,
					cd_city_farm = 0,
					cd_city_trade = 0,
				},
				sums = {
					sum_login_count = player.login_count,
					sum_user_modify = player.user_set_info,
					sum_signin_count = player.daiy_sign_count,

					sum_hall_taxes_count = player.hall_gain_count,
					sum_hall_taxes_coins = player.hall_gain_coins,
					sum_hall_taxes_feeds = player.hall_gain_feeds,

					sum_trains_train_count = player.hero_train_count,

					sum_field_harvest_count = player.pve_gain_count,
					sum_field_harvest_coins = player.pve_gain_coins,
					sum_field_harvest_feeds = player.pve_gain_feeds,

					sum_task_finish = 0,
					sum_task_commit = player.achieve_commint_count,

					sum_pve_city_num = player.pve_city_fight_count,
					sum_pve_wild_num = player.pve_monster_fight_count,
					sum_pve_wild_win = player.pve_monster_kill_count,

					sum_pvp_fire_num = player.pvp_foray_count,
					sum_pvp_fire_win = player.pvp_foray_win_count,
					sum_pvp_back_num = player.pvp_against_count,
					sum_pvp_back_win = player.pvp_against_win_count,
					sum_pvp_grade_max = player.pvp_grade_max,
					sum_pvp_medal_max = player.pvp_medal_max,

					sum_brief_play = player.battle_replay_total,
					sum_store_count = player.stall_buy_count,
					sum_chest_count = player.chest_open_total,
					sum_speak_count = player.use_speaker_total,
					sum_contr_hero = player.contract_eat_count,
					sum_contr_prob = player.contract_use_count,
					sum_arrive_count = player.hero_arrive_total,
					sum_friend_count = 0,

					sum_unit_skill_unlock_count = player.hero_skill_unlock_count,
					sum_unit_wine_count = player.hero_wine_count,
					sum_unit_max_power = player.Arrange_power_max,
				},
				vips = {
					vips = player.vip_level,
					time = player.vip_Time - math.floor(skynet.time());
				},
				--task = {},
				hall = {
					levy = player.day_gain_count, --已征收次数
					time = player.last_gain_time, --下次征收剩余时间(单位:s)，若不能征收则为-1
				},
				--rank = {},
				--boat = {},
				tavern = tavern_data,
				trains = {
					seats = {
						{ indx = player.seat_0.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_0.UnitId, mode = player.seat_0.LastMode, time = player.seat_0.CoolTime },
						{ indx = player.seat_1.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_1.UnitId, mode = player.seat_0.LastMode, time = player.seat_1.CoolTime },
						{ indx = player.seat_2.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_2.UnitId, mode = player.seat_0.LastMode, time = player.seat_2.CoolTime },
						{ indx = player.seat_3.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_3.UnitId, mode = player.seat_0.LastMode, time = player.seat_3.CoolTime },
						{ indx = player.seat_4.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_4.UnitId, mode = player.seat_0.LastMode, time = player.seat_4.CoolTime },
					}
				},
				dailys = {
					signin = {
						sign_num = 0,
						time = 0,
						items = {},
					}
				},
				charge = {
					goodss = {
						{
							type = "VIP",
							uuid = 0,
							ggid = "google",
							asid = "apple",
							name = "",
							desc = "",
							icon = "",
							give = "",
							time = 0,
							price = 10.0,
							magnification = 1.0,
							can_buy = true,
							gains = {
								conf = 1,
								num = 1,
							}
						}
					}
				},
				res_buy = {
					coins_total = 0,
					feeds_total = 0,
					coins_count = 0,
					feeds_count = 0,
					revenge_count = 0,
					revenge_use = 0,
					speaker_use = 0,
				},

				--unit = {},
				arrg = {
					used = 0,
					items = {
						{
							index = 0,
							stands = {},
						},
						{
							index = 1,
							stands = {},
						},
						{
							index = 2,
							stands = {},
						}
					}
				},
				pvp_arrg = {
					used = 0,
					items = {
						{
							index = 0,
							stands = {},
						},
						{
							index = 1,
							stands = {},
						},
						{
							index = 2,
							stands = {},
						}
					}
				},

				prop = {
					items = porp_data,
				},
				equip = {
					items = equip_data,
				},
				--store = {},
				stall = {
					cost = -1,
					time = 0,
					goodss = {
						{ uuid = 0, conf = 0, num = 1, sale = false, price_coins = 100, price_jewel = -1 }
					}
				},

				--inform = {},
				--notice = {},
				--friend = {},
				--shield = {},
				--forum = {},
				--field = {},
				--brief = {},
				--revenge = {},
				--city = {}, --pvp城市数据
				--kingdom = {}, --pvp势力数据
				--troop = {}, --pvp军团数据
			},
			gg_major = "1.36.0",
			gg_minor = "0055",
			gc_major = "1.36.0",
			gc_minor = "0055",
			req_id = lastMsgId,
		}
		util.dump(resp_data)
		send_package(pbcoder.encode(msgdef.message.LoginAuthResp, resp_data))
	end
end

function REQUEST.message.LoginPingReq(msg_obj)
	local data = pbcoder.encode(msgdef.message.LoginPingResp,
	{
		code = "SUCCEED"
	})
	send_package(data)
end

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

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		skynet.error("msg length:", sz)
		return skynet.tostring(msg, sz)
	end,
	dispatch = function (_, _, msg)
		local msgid, msg_name, msg_obj = pbcoder.decode(msg)
		local rt= {}
		lastMsgId = msgid
		string.gsub(msg_name, '[^.]+', function(w) table.insert(rt, w) end )
		if REQUEST[rt[1]] ~= nil and REQUEST[rt[1]][rt[2]] ~= nil then
			REQUEST[rt[1]][rt[2]](msg_obj)
		else
			skynet.error("agent服务没有定义" .. msg_name .. "协议处理函数")
		end
	end
}

skynet.init(function()
	service_player = skynet.queryservice("player")
end)

skynet.start(function()
	skynet.dispatch("lua", function(_, _, command, ...)
		skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
