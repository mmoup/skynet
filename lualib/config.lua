local json = require "cjson"
local util = require "util"
local skynet = require "skynet"
local sharetable = require "skynet.sharetable"

skynet.start(function()
    skynet.error("load config")
    sharetable.loadtable('Activity', json.decode(util.file_load('./config/Activity.json')))
    sharetable.loadtable('Anim', json.decode(util.file_load('./config/Anim.json')))
    sharetable.loadtable('Chest', json.decode(util.file_load('./config/Chest.json')))
    sharetable.loadtable('Equip', json.decode(util.file_load('./config/Equip.json')))
    sharetable.loadtable('Field', json.decode(util.file_load('./config/Field.json')))
    sharetable.loadtable('Lang', json.decode(util.file_load('./config/Lang.json')))
    -- config.t = json.decode(util.file_load('./config/Pawn.json'))
    sharetable.loadtable('Pays', json.decode(util.file_load('./config/Pays.json')))
    sharetable.loadtable('Prop', json.decode(util.file_load('./config/Prop.json')))
    sharetable.loadtable('Roboot', json.decode(util.file_load('./config/Roboot.json')))
    sharetable.loadtable('Setup', json.decode(util.file_load('./config/Setup.json')))
    sharetable.loadtable('Skill', json.decode(util.file_load('./config/Skill.json')))
    sharetable.loadtable('Store', json.decode(util.file_load('./config/Store.json')))
    sharetable.loadtable('Task', json.decode(util.file_load('./config/Task.json')))
    sharetable.loadtable('Tour', json.decode(util.file_load('./config/Tour.json')))
    sharetable.loadtable('Unit', json.decode(util.file_load('./config/Unit.json')))
    sharetable.loadtable('User', json.decode(util.file_load('./config/User.json')))
    sharetable.loadtable('Wall', json.decode(util.file_load('./config/Wall.json')))
    sharetable.loadtable('Wild', json.decode(util.file_load('./config/Wild.json')))
    skynet.error('load config completed')
end)