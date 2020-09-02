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
local sharetable = require "skynet.sharetable"

local WATCHDOG
local host
local send_request
local lastMsgId = 0

local CMD = {}
local REQUEST = {}

-- 网络接口
local client_fd
-- 虚拟服务
local city_service_addr
local player_service_addr
local vland_service_addr

local building_config = {}
local city_config = {}

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
	local player_id = result.user_id

	vland_service_addr = skynet.call(player_service_addr, "lua", "Login", player_id)
	-- skynet.error(util.dump(city_config))

	local function get_building_conf(code, city_conf)
		if city_conf ~= nil then
			local race
			for k, v in pairs(city_config.cityItemList) do
				if city_conf == v.guid then
					race = v.race
				end
			end
			for k, v in pairs(building_config) do
				if code == v.code and race == v.race then
					return v.guid
				end
			end
		else
			for k, v in pairs(building_config) do
				if code == v.code then
					return v.guid
				end
			end
		end
	end
	skynet.error(util.dump(building_config))

	--关卡数据
	local stronghold = skynet.call(vland_service_addr, "lua", "GetStronghold")
	local field_resp = {
		mode = "CREATE",
		field = {
			timer = 600,
			items = {},
		}
	}
	for k, v in pairs(stronghold) do
		table.insert( field_resp.field.items, {
			conf = v.city_id,
			is_mine = false,
			user_acct = -1,
			wild_city = -1,
			wild_type = "THIEVES",
			wild_units = {},
			yield_coins = 240.0,
			yield_feeds = 67.0,
			yield_jewel = 0.0
		} )
	end
	skynet.error(util.dump(field_resp))

	--城市数据
	local city_data = skynet.call(city_service_addr, "lua", "GetAllCity")
	skynet.error("city##", #city_data)
	local city_resp = {
		mode = "CREATE",
		cities = {
			items = {}
		}
	}
	for k, v in pairs(city_data) do
		skynet.error("city###", k)
		if v.conf > 0 then
			--skynet.error(util.dump(v))
			local castellan_data = {}
			if v.castellan_id > 0 then
				local castellan = skynet.call(player_service_addr, "lua", "GetPlayer", v.castellan_id)
				if castellan ~= nil then
					castellan_data = {
						acct = castellan.acct,
						name = castellan.name,
						icon = castellan.icon,
						flag = castellan.flag,
						level = castellan.level,
						is_online = castellan.online == "true",
						vip_level = castellan.vip_level,
						vip_expire_time = 0,
						contribution = 0,
						contributionRate = 0.0,
						contributionRank = 1,
						job = "LEADER",
					}
				else
					castellan_data = {
						acct = 0,
						name = "虚拟城主",
						icon = "0m",
						flag = "0+00",
						level = 1,
						is_online = false,
						vip_level = 0,
					}
				end
			else
				castellan_data = {
					acct = 0,
					name = "虚拟城主",
					icon = "0m",
					flag = "0+00",
					level = 1,
					is_online = false,
					vip_level = 0,
				}
			end
			castellan_data = {
				acct = 0,
				name = "虚拟城主",
				icon = "0m",
				flag = "0+00",
				level = 1,
				is_online = false,
				vip_level = 0,
			}
			local city = {
				id = v.id,
				conf = v.conf,
				land_conf = v.land_id,
				kingdom_id = v.kingdom_id,
				castellan = castellan_data,
				conqueror_id = v.conqueror_id,
				coins = v.coins,
				foods = v.foods,
				tax_rate = tonumber(v.tax_rate * 100),
				bulletin = v.bulletin,
				units = {},
				market = {
					conf = get_building_conf("market"),
					level = v.market_level,
					exp = v.market_exp,
				},
				farm = {
					conf = get_building_conf("farm"),
					level = v.farm_level,
					exp = v.farm_exp,
				},
				tavern = {
					conf = get_building_conf("tavern"),
					level = v.hall_level,
					exp = v.hall_exp,
				},
				gate = {
					conf = get_building_conf("gate", v.conf),
					level = v.gate_level,
					exp = v.gate_exp,
				},
				warehouse = {
					conf = get_building_conf("warehouse"),
					level = v.warehouse_level,
					exp = v.warehouse_exp,
					coins = v.coins,
					feeds = v.foods,
				},
				ground = {
					conf = get_building_conf("ground"),
					level = v.ground_level,
					exp = v.ground_exp,
					ground_content = v.bulletin,
				},
				hall = {
					conf = get_building_conf("hall", v.conf),
					level = v.hall_level,
					exp = v.hall_exp,
				},
				house = {
					conf = get_building_conf("house"),
					level = v.house_level,
					exp = v.house_exp,
				},
				towers = {
					{
						conf = get_building_conf("tower", v.conf),
						level = v.tower0_level,
						exp = v.tower0_exp,
					},
					{
						conf = get_building_conf("tower", v.conf),
						level = v.tower1_level,
						exp = v.tower1_exp,
					},
					{
						conf = get_building_conf("tower", v.conf),
						level = v.tower2_level,
						exp = v.tower2_exp,
					},
					{
						conf = get_building_conf("tower", v.conf),
						level = v.tower3_level,
						exp = v.tower3_exp,
					},
				},
				members = {},
				Applicant = {},
				transport_tasks = {},
				arrg = {},
				ground_hero_level = v.ground_hero_level,
				ground_unit_level = v.ground_unit_level,
				farm_rate = v.farm_rate,
				market_rate = v.market_rate,
				cd_appoint = -1,
				member_min_level = 1,
			}
			table.insert( city_resp.cities.items, city )
		end
	end
	skynet.error(util.dump(city_resp))

	--获取玩家信息
	local player = skynet.call(vland_service_addr, "lua", "GetPlayer")

	--获取酒馆数据
	local tavern = skynet.call(vland_service_addr, "lua", "GetTavern")
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
	local tavern_resp = {
		mode = "CREATE",
		tavern = tavern_data,
	}

	--装备
	local equip = skynet.call(vland_service_addr, "lua", "GetEquip")
	local equip_data = {}
	for k, v in pairs(equip) do
		table.insert( equip_data, { conf = v.item_id, num = v.sum_num } )
	end

	--道具
	local porp = skynet.call(vland_service_addr, "lua", "GetProp")
	local porp_data = {}
	for k, v in pairs(porp) do
		table.insert( porp_data, { conf = v.id, num = v.num } )
	end

	local shop_item_data = {}
	for i=0, 11 do
		local rt = {}
		string.gsub(player["good_" .. i], '[^|]+', function(w) table.insert(rt, w) end )
		table.insert( shop_item_data, {
			uuid = tonumber(rt[1]),
			conf = player["good_" .. i],
			num = 1,
			sale = "true" == rt[2],
			price_coins = 10,
			price_jewel = -1,
		} )
	end

	local resp_data = {
		code = "SUCCEED",
		acct = {
			user = {
				acct = player.acct,
				name = player.name,
				icon = "0m",
				flag = "n09",
				expss = player.exp,
				level = player.level,
				land_id = player.server,
				kingdom_id = player.kingdom_id,
				city_id = -1000011,
				current_field_conf = 60000034,
				from_field_conf = 60000091,
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
			--tavern = {},
			trains = {
				seats = {
					{ indx = player.seat_0.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_0.UnitId, mode = player.seat_0.LastMode, time = player.seat_0.CoolTime },
					{ indx = player.seat_1.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_1.UnitId, mode = player.seat_1.LastMode, time = player.seat_1.CoolTime },
					{ indx = player.seat_2.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_2.UnitId, mode = player.seat_2.LastMode, time = player.seat_2.CoolTime },
					{ indx = player.seat_3.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_3.UnitId, mode = player.seat_3.LastMode, time = player.seat_3.CoolTime },
					{ indx = player.seat_4.Id, is_open=player.seat_0.Open, unit_uuid = player.seat_4.UnitId, mode = player.seat_4.LastMode, time = player.seat_4.CoolTime },
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
				used = 2,
				items = {
					{
						index = 0,
						stands = {
							--{ conf = 0, ipos = 6, order = "cmd_attack", prof = "SWORD"}
						},
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
				time = player.last_flush_time,
				goodss = shop_item_data,
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
		gg_major = "1.45.0",
		gg_minor = "0105",
		gc_major = "1.45.0",
		gc_minor = "0105",
		--req_id = lastMsgId,
	}
	skynet.error(util.dump(resp_data))

	local unit_data = skynet.call(vland_service_addr, "lua", "GetUnit", player_id)
	local unit_sync_resp = {
		mode = "CREATE",
		unit = {
			items = {
			}
		},
	}
	for _, v in pairs(unit_data) do
		table.insert( unit_sync_resp.unit.items, {
			uuid = v.unit_uuid,
			power = 100,
			expss = v.pawn_exp,
			grade = v.grade,
			drink_time = v.wine_times,
			energy = 1000,
			hero_conf = v.hero_id,
			hero_star = v.star,
			hero_star_list = { v.hero_s1, v.hero_s2, v.hero_s3 },
			hero_expss = v.herp_exp,
			hero_level = v.hero_lv,
			hero_skill_lv1 = 0,
			hero_skill_lv2 = 0,
			hero_skill_lv3 = 0,
			hero_equip_weapon = 0,
			hero_equip_helmet = 0,
			hero_equip_armour = 0,
			hero_equip_caliga = 0,
			hero_stass_total = {},
			hero_stass_equip = {},
			hero_stass_wine = {},
			eat_equips = json.decode(v.eat_equips),
			pawn_conf = v.pawn_id,
			pawn_stass = {},
			pawn_num = v.pawn_num,
			prof = "",
			action = "IDLE",
			player_name = "",
		} )
	end

	local ctor_sync_boat_resp = {
		mode = "CREATE",
		boat = {
			rank = 1,
			time = 86400,
			medal = 210,
			atk_vict = 10,
			def_vict = 0,
			awards = {
				grade = 1,
				prizes = {
					{ conf = 0, num = 0 }
				}
			},
		},
	}

	local stall_sync_resp = {
		mode = "CREATE",
		stall = {
			cost = -1,
			time = 600,
			goodss = shop_item_data,
		},
	}

	local task_sync_resp = {
		mode = "CREATE",
		task = {},
	}

	local troop_sync = {
		mode = "CREATE",
		troops = {
			items = {},
		},
	}

	local kingdom_sync = {
		mode = "CREATE",
		kingdoms = {
			items = {}
		}
	}
	local kingdom_data = skynet.call(skynet.queryservice("kingdom"), "lua", "GetKingdom")
	for _, v in pairs(kingdom_data) do
		table.insert( kingdom_sync.kingdoms.items, {
			id = v.id,
			name = v.name,
			flag = "n09",
			founder = {},
			king = {
				acct = 110,
				name = "国王",
				flag = "n10",
				icon = "3m",
				level = 1,
			},
			color = v.color,
			bulletin = v.bulletin,
			created_time = 1000,
			succeeded_time = 500,
			outstanding_members = {},
			members = {},
			member_min_level = 1,
			recruit_text = "gogogo",
		} )
	end

	local war_log_sync = {
		mode = "CREATE",
		war_logs = {},
	}


	send_package(pbcoder.encode(msgdef.message.LoginAuthResp, resp_data))

	send_package(pbcoder.encode(msgdef.message.FieldSyncResp, field_resp))

	local field_sync_resp_append = {
		mode = "APPEND",
		field = {
			timer = 0,
			items = {
				conf = 60101832,
				wild_city = 60000091,
				wild_drop_coins = 175,
				wild_drop_feeds = 128,
				wild_drop_ids = {
					33000005, 31100001
				},
				wild_drop_num = {
					1, 1
				},
				wild_hero_expss = 610,
				wild_jcost = 38,
				wild_level = 8,
				wild_name = "盗贼",
				wild_time = 180,
				wild_type = "THIEVES",
				wild_unit_expss = 995,
				wild_units = {
					{
						grade = 1,
						hero_conf = 10011044,
						hero_level = 8,
						ipos = 1,
						order = "cmd_attack",
					}
				},
			},
		},
	}
	send_package(pbcoder.encode(msgdef.message.FieldSyncResp, field_sync_resp_append))
	--append

	--create {message.UnitSyncResp}
	skynet.error(util.dump(unit_sync_resp))
	send_package(pbcoder.encode(msgdef.message.UnitSyncResp, unit_sync_resp))

	--create {message.CtorSyncBoatResp}
	send_package(pbcoder.encode(msgdef.message.CtorSyncBoatResp, ctor_sync_boat_resp))

	--create {message.StallSyncResp}
	send_package(pbcoder.encode(msgdef.message.StallSyncResp, stall_sync_resp))

	--create {message.TaskSyncResp}
	send_package(pbcoder.encode(msgdef.message.TaskSyncResp, task_sync_resp))

	tavern_resp = {
		mode = "CREATE",
		tavern = {},
	}
	send_package(pbcoder.encode(msgdef.message.CtorSyncTavernResp, tavern_resp))

	send_package(pbcoder.encode(msgdef.message.CitySync, city_resp))

	--troop sync {message.TroopSync}
	send_package(pbcoder.encode(msgdef.message.TroopSync, troop_sync))

	--{message.KingdomSync}
	send_package(pbcoder.encode(msgdef.message.KingdomSync, kingdom_sync))

	--{message.WarLogSync}
	send_package(pbcoder.encode(msgdef.message.WarLogSync, war_log_sync))

	--{message.StallSyncResp}
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
	player_service_addr = skynet.queryservice("player")
	city_service_addr = skynet.queryservice("city")
	building_config = sharetable.query("building")
	city_config = sharetable.query("city")
end)

skynet.start(function()
	skynet.dispatch("lua", function(_, _, command, ...)
		skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
