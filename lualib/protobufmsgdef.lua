local M = {}
local msg_map = {}

M.message = {
    -- 服务器准备完毕
    REQ_SERVER_READY = 1,

    -- 帧率
    REQ_SERVER_UPDATE = 2,

    -- 固定帧更新
    REQ_SERVER_FIXED_UPDATE = 3,

    --  登录认证
    LoginAuthReq = 100,

    LoginAuthResp = 101,

    --  发出PING
    LoginPingReq = 102,

    LoginPingResp = 103,

    --  发出GCM码
    REQ_LOGIN_GCM = 104,

    RESP_LOGIN_GCM = 105,

    --  同步登录数据
    RESP_LOGIN_SYNC = 106,

    --  发起&回应登出上报
    REQ_EXIT_AUTH = 107,

    RESP_EXIT_AUTH = 108,


    REQ_PROFILE = 109,

    RESP_PROFILE = 110,

    --  登录上报
    REQ_LOGIN_REPORT = 111,

    --  服务器状态维护
    RESP_MAINTENANCE = 112,

    --  GameServer发送到PVPServer
    REQ_LOGIN_PVP = 113,

    RESP_LOGIN_PVP = 114,

    REQ_LOGOUT_PVP = 115,

    RESP_LOGOUT_PVP = 116,

    -- update
    REQ_UPDATE_PVP = 117,

    RESP_UPDATE_PVP = 118,

    --[[用户模块]]
    --  创建用户
    UserCreateReq = 200,

    UserCreateResp = 201,

    --  查询用户
    UserQuestReq = 202,

    UserQuestResp = 203,

    --  获取随机用户名
    UserNameReq = 204,

    UserNameResp = 205,

    --  同步用户经验等级
    RESP_USER_SYNC_LEVEL = 206,

    --  同步用户资源
    RESP_USER_SYNC_RES = 207,

    --  同步用户PVP数据
    RESP_USER_SYNC_PVP = 208,

    --  同步VIP数据
    RESP_VIPS_SYNC = 400,

    --  成就提交
    REQ_TASK_COMMIT = 600,

    RESP_TASK_COMMIT = 601,

    --  同步成就
    TaskSyncResp = 602,

    --  签到
    REQ_DAILYS_SIGNIN_DOIT = 800,

    RESP_DAILYS_SIGNIN_DOIT = 801,

    --  同步活动签到数据
    RESP_DAILYS_SYNC_SIGNIN = 802,

    --  同步付费商品数据
    RESP_CHARGE_SYNC_GOODS = 1000,

    --  同步付费物品数据
    RESP_CHARGE_SYNC_GAINS = 1001,

    --  政厅征收
    REQ_CTOR_HALL_TAXES = 1200,

    RESP_CTOR_HALL_TAXES = 1201,
    --  排行榜查询
    REQ_CTOR_RANK_QUEST = 1202,

    RESP_CTOR_RANK_QUEST = 1203,
    --  酒馆座位解锁
    REQ_CTOR_TAVERN_UNLOCK = 1204,

    RESP_CTOR_TAVERN_UNLOCK = 1205,

    --  酒馆增加到访率
    REQ_CTOR_TAVERN_ARRIVE = 1206,

    RESP_CTOR_TAVERN_ARRIVE = 1207,

    --  训练场座位解锁
    REQ_CTOR_TRAINS_UNLOCK = 1208,

    RESP_CTOR_TRAINS_UNLOCK = 1209,

    --  同步政厅数据
    RESP_CTOR_SYNC_HALL = 1210,

    --  同步排行榜数据
    RESP_CTOR_SYNC_RANK = 1211,

    --  同步远征数据
    CtorSyncBoatResp = 1212,

    --  同步酒馆数据
    CtorSyncTavernResp = 1213,

    --  同步训练数据
    RESP_CTOR_SYNC_TRAINS = 1214,

    --  英雄招募
    REQ_UNIT_HERO_RECRUIT = 1400,

    RESP_UNIT_HERO_RECRUIT = 1401,

    -- 英雄宴请
    REQ_UNIT_BANQUET = 1402,

    RESP_UNIT_BANQUET = 1403,

    --  英雄喝酒
    REQ_UNIT_HERO_WINE = 1404,

    RESP_UNIT_HERO_WINE = 1405,

    --  英雄升级
    REQ_UNIT_HERO_UPGRADE = 1406,

    RESP_UNIT_HERO_UPGRADE = 1407,

    --  英雄训练
    REQ_UNIT_HERO_TRAIN = 1408,

    RESP_UNIT_HERO_TRAIN = 1409,

    --  英雄装备
    REQ_UNIT_HERO_EQUIP = 1410,

    RESP_UNIT_HERO_EQUIP = 1411,

    --  英雄脱装备
    REQ_UNIT_HERO_EQUIP_TAKEOFF = 1412,

    RESP_UNIT_HERO_EQUIP_TAKEOFF = 1413,

    --  英雄升星
    REQ_UNIT_HERO_STARS = 1414,

    RESP_UNIT_HERO_STARS = 1415,

    --  英雄降星
    REQ_UNIT_HERO_STAR_DEGRADE = 1416,

    RESP_UNIT_HERO_STAR_DEGRADE = 1417,

    --  英雄技能解锁
    REQ_UNIT_HERO_SKILL_UNLOCK = 1418,

    RESP_UNIT_HERO_SKILL_UNLOCK = 1419,

    --  英雄技能升级
    REQ_UNIT_HERO_SKILL_UPGRADE = 1420,

    RESP_UNIT_HERO_SKILL_UPGRADE = 1421,

    --  部队士兵扩容
    REQ_UNIT_PAWN_EXTENSION = 1422,

    RESP_UNIT_PAWN_EXTENSION = 1423,

    --  部队进阶
    REQ_UNIT_ADVANCES = 1424,

    RESP_UNIT_ADVANCES = 1425,

    --  部队转职
    REQ_UNIT_TRANSFER = 1426,

    RESP_UNIT_TRANSFER = 1427,

    --  部队布阵
    REQ_UNIT_ARRANGE = 1428,

    RESP_UNIT_ARRANGE = 1429,

    --  同步部队
    UnitSyncResp = 1430,

    --  道具购买
    REQ_PROP_BUY = 1600,

    RESP_PROP_BUY = 1601,

    --  道具使用
    REQ_PROP_USE = 1602,

    RESP_PROP_USE = 1603,

    --  道具合成
    REQ_PROP_SYNTHETIC = 1604,

    RESP_PROP_SYNTHETIC = 1605,

    --  同步道具
    RESP_PROP_SYNC = 1606,

    --  分解装备
    REQ_EQUIP_DECOMPOSE = 1800,

    RESP_EQUIP_DECOMPOSE = 1801,

    --  打造装备
    REQ_EQUIP_CREAT = 1802,

    RESP_EQUIP_CREAT = 1803,

    --  同步装备
    RESP_EQUIP_SYNC = 1804,

    --  商品购买
    REQ_STORE_BUY = 2000,

    RESP_STORE_BUY = 2001,

    --  商店刷新
    REQ_STORE_REFRESH = 2002,

    RESP_STORE_REFRESH = 2003,

    --  同步商店
    RESP_STORE_SYNC = 2004,

    --  关卡收获
    REQ_FIELD_HARVEST = 2200,

    RESP_FIELD_HARVEST = 2201,

    --  送走野怪
    REQ_FIELD_PACKOFF = 2202,

    RESP_FIELD_PACKOFF = 2203,

    --  关卡同步数据
    FieldSyncResp = 2204,

    --  据点间移动
    REQ_FIELD_MOVE = 2205,

    RESP_FIELD_MOVE = 2206,

    --  战报已阅
    REQ_BRIEF_READ = 2400,

    RESP_BRIEF_READ = 2401,

    --  战报同步数据
    RESP_BRIEF_SYNC = 2402,

    --  复仇列表同步
    RESP_REVENGE_SYNC = 2403,

    --  PVP战役同步 服务器间
    RESP_WAR_LOG_SYNC_TO_GAME = 2404,

    --  PVP战役同步
    WarLogSync = 2405,

    -- PVP战役详情
    REQ_WAR_LOG_DETAIL = 2406,

    RESP_WAR_LOG_DETAIL = 2407,

    --  世界聊天
    REQ_CHAT_SPEAK_WORLD = 2600,

    RESP_CHAT_SPEAK_WORLD = 2601,

    --  大陆聊天
    REQ_CHAT_SPEAK_LAND = 2602,

    RESP_CHAT_SPEAK_LAND = 2603,

    --  城池聊天
    REQ_CHAT_SPEAK_CITY = 2604,

    RESP_CHAT_SPEAK_CITY = 2605,

    --  势力聊天
    REQ_CHAT_SPEAK_KINGDOM = 2606,

    RESP_CHAT_SPEAK_KINGDOM = 2607,

    --  私聊
    REQ_CHAT_SPEAK_PRIVATE = 2608,

    RESP_CHAT_SPEAK_PRIVATE = 2609,

    --  同步数据
    RESP_CHAT_SYNC = 2610,

    --  同步联系人
    RESP_CHAT_CONT_SYNC = 2611,

    -- 拉取聊天记录
    REQ_CHAT_FETCH_HISTORY = 2612,

    RESP_CHAT_FETCH_HISTORY = 2613,

    --  公告同步数据
    RESP_INFORM_SYNC = 2800,

    --  通知读取
    REQ_NOTICE_READ = 3000,

    RESP_NOTICE_READ = 3001,

    --  通知删除
    REQ_NOTICE_DELETE = 3002,

    RESP_NOTICE_DELETE = 3003,

    --  通知接受
    REQ_NOTICE_ACCEPT = 3004,

    RESP_NOTICE_ACCEPT = 3005,

    --  通知拒绝
    REQ_NOTICE_REFUSE = 3006,

    RESP_NOTICE_REFUSE = 3007,

    --  通知同步数据
    RESP_NOTICE_SYNC = 3008,

    --  好友搜索
    REQ_FRIEND_SEARCH = 3200,

    RESP_FRIEND_SEARCH = 3201,

    --  好友添加
    REQ_FRIEND_APPEND = 3202,

    RESP_FRIEND_APPEND = 3203,

    --  好友删除
    REQ_FRIEND_REMOVE = 3204,

    RESP_FRIEND_REMOVE = 3205,

    --  好友赠送
    REQ_FRIEND_GIVE = 3206,

    RESP_FRIEND_GIVE = 3207,

    --  好友收取赠送
    REQ_FRIEND_RECV = 3208,

    RESP_FRIEND_RECV = 3209,

    --  好友同步数据
    RESP_FRIEND_SYNC = 3210,

    --  屏蔽添加
    REQ_SHIELD_APPEND = 3400,

    RESP_SHIELD_APPEND = 3401,

    --  屏蔽删除
    REQ_SHIELD_REMOVE = 3402,

    RESP_SHIELD_REMOVE = 3403,

    --  屏蔽同步数据
    RESP_SHIELD_SYNC = 3404,

    --  讨论组创建
    REQ_FORUM_CREATE = 3600,

    RESP_FORUM_CREATE = 3601,

    --  讨论组删除
    REQ_FORUM_DELETE = 3602,

    RESP_FORUM_DELETE = 3603,

    --  讨论组添加
    REQ_FORUM_APPEND = 3604,

    RESP_FORUM_APPEND = 3605,

    --  讨论组踢出
    REQ_FORUM_REMOVE = 3606,

    RESP_FORUM_REMOVE = 3607,

    --  讨论组禁言
    REQ_FORUM_FORBID = 3608,

    RESP_FORUM_FORBID = 3609,

    --  讨论组解禁
    REQ_FORUM_PERMIT = 3610,

    RESP_FORUM_PERMIT = 3611,

    --  讨论组同步数据
    RESP_FORUM_SYNC = 3612,

    --  PVE战斗开始
    REQ_FIGHT_PVE_START = 3800,

    RESP_FIGHT_PVE_START = 3801,

    --  PVE战斗结束
    REQ_FIGHT_PVE_GOVER = 3802,

    RESP_FIGHT_PVE_GOVER = 3803,
    --  PVE防守阵形
    REQ_FIGHT_PVE_GUARD = 3804,

    RESP_FIGHT_PVE_GUARD = 3805,

    --  PVP战斗搜索
    REQ_FIGHT_PVP_CLOUD = 3806,

    RESP_FIGHT_PVP_CLOUD = 3807,

    --  PVP战斗搜索放弃
    REQ_FIGHT_PVP_ABORT = 3808,

    RESP_FIGHT_PVP_ABORT = 3809,

    --  PVP战斗开始(计算)
    REQ_FIGHT_PVP_START = 3810,

    RESP_FIGHT_PVP_START = 3811,

    --  PVP战斗查询
    REQ_FIGHT_PVP_QUEST = 3812,

    RESP_FIGHT_PVP_QUEST = 3813,

    --  PVP 复仇申请
    REQ_FIGHT_PVP_REVENGE_SEARCH = 3814,

    RESP_FIGHT_PVP_REVENGE_SEARCH = 3815,

    --  同步统计信息
    RESP_SUMS_SYNC = 4000,

    --  商品购买
    REQ_STALL_BUY = 4200,

    RESP_STALL_BUY = 4201,

    --  商店刷新
    REQ_STALL_REFRESH = 4202,

    RESP_STALL_REFRESH = 4203,

    --  同步商店
    StallSyncResp = 4204,

    -- 资源购买
    REQ_RESOURCES_BUY = 4400,

    RESP_RESOURCES_BUY = 4401,

    --  同步资源购买剩余次数数据
    RESP_RESOURCES_SYNC = 4402,

    CitySync = 4500,

    RESP_CITY_SYNC_TO_GAME = 4501,

    -- 城市城墙防守阵型调整
    REQ_CITY_WALL_EMBATTLE = 4502,

    RESP_CITY_WALL_EMBATTLE = 4503,

    -- 城市城墙防守成型激活
    REQ_CITY_WALL_SET_ARRG = 4504,

    RESP_CITY_WALL_SET_ARRG = 4505,

    -- 城市校场进攻阵型调整
    REQ_CITY_GROUND_EMBATTLE = 4506,

    RESP_CITY_GROUND_EMBATTLE = 4507,

    -- 城市校场进攻阵型默认设置
    REQ_CITY_GROUND_SET_ARRG = 4508,

    RESP_CITY_GROUND_SET_ARRG = 4509,

    -- 开垦
    REQ_CITY_FARM = 4510,

    RESP_CITY_FARM = 4511,

    -- 贸易
    REQ_CITY_TRADE = 4512,

    RESP_CITY_TRADE = 4513,

    -- 运输
    REQ_CITY_TRANSPORT = 4514,

    RESP_CITY_TRANSPORT = 4515,

    -- 驻防
    REQ_CITY_GUARD = 4516,

    RESP_CITY_GUARD = 4517,

    -- 撤防
    REQ_CITY_DISARM = 4518,

    RESP_CITY_DISARM = 4519,

    -- 升级建筑
    REQ_CITY_UPGRADE = 4520,

    RESP_CITY_UPGRADE = 4521,

    -- 建造
    REQ_CITY_BUILD = 4522,

    RESP_CITY_BUILD = 4523,

    -- 驱逐居民
    REQ_CITY_EXPEL = 4524,

    RESP_CITY_EXPEL = 4525,

    -- 设定税率
    REQ_CITY_SET_RATE = 4526,

    RESP_CITY_SET_RATE = 4527,

    -- 发布运输任务
    REQ_CITY_TRANSPORT_TASK = 4528,

    RESP_CITY_TRANSPORT_TASK = 4529,

    -- 终止运输任务
    REQ_CITY_TRANSPORT_TASK_CANCEL = 4530,

    RESP_CITY_TRANSPORT_TASK_CANCEL = 4531,

    -- 脱离城市
    REQ_CITY_LEAVE = 4532,

    RESP_CITY_LEAVE = 4533,

    -- 查询驻防部队
    REQ_CITY_GROUND_QUERY_UNITS = 4534,

    RESP_CITY_GROUND_QUERY_UNITS = 4535,

    -- 邀请玩家定居
    REQ_CITY_INVITE = 4536,

    RESP_CITY_INVITE = 4537,

    -- 玩家接受邀请
    REQ_CITY_INVITATION_ACCEPT = 4538,

    RESP_CITY_INVITATION_ACCEPT = 4539,

    -- 玩家拒绝邀请
    REQ_CITY_INVITATION_REJECT = 4540,

    RESP_CITY_INVITATION_REJECT = 4541,

    -- 请求定居
    REQ_CITY_APPLY = 4542,

    RESP_CITY_APPLY = 4543,

    -- 同意请求
    REQ_CITY_APPLICATION_ACCEPT = 4544,

    RESP_CITY_APPLICATION_ACCEPT = 4545,

    -- 拒绝请求
    REQ_CITY_APPLICATION_REJECT = 4546,

    RESP_CITY_APPLICATION_REJECT = 4547,

    -- 拉取居民
    REQ_CITY_QUERY_MEMBERS = 4547,

    RESP_CITY_QUERY_MEMBERS = 4549,

    -- 设定公告
    REQ_CITY_SET_BULLETIN = 4550,

    RESP_CITY_SET_BULLETIN = 4551,

    -- 设定校场标准
    REQ_CITY_GROUND_SET_CONDITION = 4552,

    RESP_CITY_GROUND_SET_CONDITION = 4553,

    -- 拉取申请定居列表
    REQ_CITY_QUERY_APPLICANT = 4554,

    RESP_CITY_QUERY_APPLICANT = 4555,

    -- 拉取城市任务
    REQ_CITY_QUERY_TASKS = 4556,

    RESP_CITY_QUERY_TASKS = 4557,

    -- 拉取设施信息
    REQ_CITY_QUERY_BUILDING_IFNO = 4558,

    RESP_CITY_QUERY_BUILDING_IFNO = 4559,

    KingdomSync = 4700,

    RESP_KINGDOM_SYNC_TO_GAME = 4701,

    -- 任命城主
    REQ_KINGDOM_APPOINT = 4702,

    RESP_KINGDOM_APPOINT = 4703,

    -- 国王传位
    REQ_KINGDOM_ABDICATE = 4704,

    RESP_KINGDOM_ABDICATE = 4705,

    -- 城主独立
    REQ_KINGDOM_INDEPENDENCE = 4706,

    RESP_KINGDOM_INDEPENDENCE = 4707,

    -- 国王劝降
    REQ_KINGDOM_SURRENDER = 4708,

    RESP_KINGDOM_SURRENDER = 4709,

    -- 城主投降
    REQ_KINGDOM_CAPITULATE = 4710,

    RESP_KINGDOM_CAPITULATE = 4711,

    -- 势力更名
    REQ_KINGDOM_RENAME = 4712,

    RESP_KINGDOM_RENAME = 4713,

    -- 接受城主任命
    REQ_KINGDOM_APPOINTMENT_ACCEPT = 4714,

    RESP_KINGDOM_APPOINTMENT_ACCEPT = 4715,

    -- 拒绝城主任命
    REQ_KINGDOM_APPOINTMENT_REJECT = 4716,

    RESP_KINGDOM_APPOINTMENT_REJECT = 4717,

    -- 撤职城主
    REQ_KINGDOM_FIRE = 4718,

    RESP_KINGDOM_FIRE = 4719,

    -- 搜索势力成员
    REQ_KINGDOM_MEMBER_SEARCH = 4720,

    RESP_KINGDOM_MEMBER_SEARCH = 4721,

    -- 设定势力公告
    REQ_KINGDOM_SET_BULLETIN = 4722,

    RESP_KINGDOM_SET_BULLETIN = 4723,

    -- 拉取势力详情
    REQ_KINGDOM_DETAIL = 4724,

    RESP_KINGDOM_DETAIL = 4725,

    -- 创建势力
    REQ_KINGDOM_CREATE = 4726,

    RESP_KINGDOM_CREATE = 4727,

    -- 加入势力
    REQ_KINGDOM_JOIN = 4728,

    RESP_KINGDOM_JOIN = 4729,

    -- 主动脱离势力
    REQ_KINGDOM_LEAVE = 4730,

    RESP_KINGDOM_LEAVE = 4731,

    -- 从势力中踢走成员
    REQ_KINGDOM_BAN = 4732,

    RESP_KINGDOM_BAN = 4733,

    -- 拉取成员列表
    REQ_KINGDOM_QUERY_MEMBERS = 4734,

    RESP_KINGDOM_QUERY_MEMBERS = 4735,

    -- 拉取招募势力
    REQ_KINGDOM_RECRUIT_LIST = 4736,

    RESP_KINGDOM_RECRUIT_LIST = 4737,

    -- 势力排行榜
    REQ_KINGDOM_BILLBOARD = 4738,

    RESP_KINGDOM_BILLBOARD = 4739,
    -- 使用招募令
    REQ_KINGDOM_RECRUIT = 4740,

    RESP_KINGDOM_RECRUIT = 4741,

    -- 同步势力排行榜
    RESP_KINGDOM_BILLBOARD_SYNC_TO_GAME = 4742,

    -- 设定势力参数
    REQ_KINGDOM_SET_RATE = 4743,

    RESP_KINGDOM_SET_RATE = 4744,

    --[[
        PVP军团模块
        ]]

    TroopSync = 4900,

    RESP_TROOP_SYNC_TO_GAME = 4901,

    RESP_TROOP_UNIT_SYNC = 4902,

    -- 发起集结
    REQ_TROOP_RALLY = 4903,

    RESP_TROOP_RALLY = 4904,

    -- 选择部队
    REQ_TROOP_PICK = 4905,

    RESP_TROOP_PICK = 4906,

    -- 部队出征
    REQ_TROOP_DEPART = 4907,

    RESP_TROOP_DEPART = 4908,

    -- 阵型调整
    REQ_TROOP_EMBATTLE = 4909,

    RESP_TROOP_EMBATTL = 4910,

    -- 查询军团部队
    REQ_TROOP_QUERY_UNITS = 4911,

    RESP_TROOP_QUERY_UNITS = 4912,

    -- 撤销集结
    REQ_TROOP_DISBAND = 4913,

    RESP_TROPP_DISBAND = 4914,

    -- 数据同步
    RESP_LAND_SYNC = 5100,

    RESP_LAND_SYNC_TO_GAME = 5101,

    -- 数据请求
    REQ_LAND_LIST = 5102,

    RESP_LAND_LIST = 5103,

    -- 移居入境
    REQ_LAND_IMMIGRATE = 5104,

    RESP_LAND_IMMIGRATE = 5105,

    -- 探索
    REQ_FIELD_EXPLORE = 5200,

    RESP_FIELD_EXPLORE = 5201,

    -- 集结通知接受
    REQ_GAME_GUILD_NOTIC = 10000,

    RESP_GAME_GUILD_NOTIC = 10001,

    -- 批量玩家上报
    REQ_GAME_GUILD_USER_REPORT = 10002,

    RESP_GAME_GUILD_USER_REPORT = 10003,
}

for pack_name, pack_list in pairs(M) do
    for sub_name, msgid in pairs(pack_list) do
        msg_map[msgid] = pack_name .. "." .. sub_name
    end
end

function M.get_name(msgid)
    return msg_map[msgid]
end

return M