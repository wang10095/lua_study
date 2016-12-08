ServerDataProxy = class("ServerDataProxy",function()
	return Model:create("ServerDataProxy",{
		rsp1 = 0,
		authcode = '',
		switchLogin = 0,
	})
end)

local _allowNewInstance = false
local __instance = nil

function ServerDataProxy:ctor()
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function ServerDataProxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = ServerDataProxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end