--
-- Author: hapigames
-- Date: 2014-12-04 10:59:54
--
Hotpetdataproxy = class("Hotpetdataproxy",function()
	return Model:create("Hotpetdataproxy",{
		itemtype = 0,
		itemid = 0,
		amount = 0
		})
end)
local _allowNewInstance = false
local __instance = nil
Hotpetdataproxy.hotpetList = {}

function Hotpetdataproxy:ctor()
	print("Hotpetdataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Hotpetdataproxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = Hotpetdataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end
