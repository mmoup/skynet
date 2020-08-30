local M = {}
local msg_map = {}

M.message = {
    LoginAuthReq = 100,
    LoginAuthResp = 101
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