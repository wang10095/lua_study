PlayerProxy = class("PlayerProxy",function()
	return Model:create("PlayerProxy",{
			role_id = {}, --已解锁的头像id
			randomName = "",
		})
end)
local _allowNewInstance = true
local __instance = nil
PlayerProxy.pvp1List = {}

function PlayerProxy:ctor()
	print("PlayerProxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function PlayerProxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = PlayerProxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end