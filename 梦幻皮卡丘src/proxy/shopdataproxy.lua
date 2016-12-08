--
-- Author: hapigames
-- Date: 2014-12-03 17:22:57
--
Shopdataproxy = class("Shopdataproxy",function()
	return Model:create("Shopdataproxy",{
		goods_id = 0,
		goodType = 0,
		item_type = 0,
		mid = 0,
		aptitude = 0,
		diamondtype = 0,
		diamondnum = 0,
		isbuy = 0,
		refurbishTimes = 0,
		shop_type = 0,
		item_price = 0,
		isRecharge = false,
		})
end)
local _allowNewInstance = false
local __instance = nil
Shopdataproxy.goodsList = {}
Shopdataproxy.refreshList = {0,0,0,0,0}

function Shopdataproxy:ctor()
	print("Shopdataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Shopdataproxy:getInstance()
	if (__instance == nil) then
		print("Shopdataproxy getInstance")
		_allowNewInstance = true
		__instance = Shopdataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end
