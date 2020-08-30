local skynet = require "skynet"
local protobuf = require "protobuf"      --引入文件protobuf.lua
local msgdef = require "protobufmsgdef"

protobuf.register_file "./ewar.pb" --注册pb文件


local coder = {}

function coder.encode(msgid, data)
    local msg_name = msgdef.get_name(msgid)
    local stringbuffer =  protobuf.encode(msg_name, data)         -- protobuf序列化 返回lua string
    skynet.error("send ", msg_name)
    local body = string.pack(">HHc" .. #stringbuffer, #stringbuffer, msgid, stringbuffer)       -- 打包包体 协议名 + 协议数据            -- 打包包体长度
    return body                                       -- 包体长度 + 协议名 + 协议数据
end


--[[
    @desc: 将二进制数据反序列化为lua string
    --@msg: C Point
    @return:协议名字，协议数据
]]
function coder.decode( msg  )
    --- 前两个字节在netpack.filter 已经解析
    skynet.error("msg len", #msg, msg)
    local pack_size = #msg - 2
    local msgid, stringbuffer = string.unpack(">Hc"..pack_size, msg)
    skynet.error("消息号", msgId, "包体长度", pack_size)
    local msg_name = msgdef.get_name(msgid)
    local body = protobuf.decode(msg_name, stringbuffer)
    return msgid, body
end


return coder