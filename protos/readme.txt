1. common中
阵型Arrg增加了补充规则ReplacementRule，可选字段，不影响现有功能
用户User中增加了驻地城市city_id和当前所在城市current_city_id

增加Land(大陆)、City(城市)、Troop(军团)和Kingdom(势力)4个基础数据结构
每块大陆等于1个服务器

2. User中
增加用户移动自身的消息UserMoveReq

2.之前的field对应关卡，新增加city表示城市相关

3.新增加troop表示军团相关

4.新增加kingdom表示势力相关

登陆后服务器异步返回所有城市、军团和势力的基础数据