--
-- Author: hapigames
-- Date: 2014-12-05 12:11:39
--
Mysterytoydataproxy = class("Mysterytoydataproxy",function()
	return Model:create("Mysterytoydataproxy",{
		itemtype = 0,
		itemid = 0,
		amount = 0
		})
end)
local _allowNewInstance = false
local __instance = nil
Mysterytoydataproxy.mysterytoyList = {}

function Mysterytoydataproxy:ctor()
	print("Mysterytoydataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Mysterytoydataproxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = Mysterytoydataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end