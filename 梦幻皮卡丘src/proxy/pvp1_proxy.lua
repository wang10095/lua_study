SilverChampionShipproxy = class("SilverChampionShipproxy",function()
	return Model:create("SilverChampionShipproxy",{
			teamid = "",
			ranking = 0,
			win_num = 0, 
			remaintime = 0, --剩余挑战次数 
		})
end)
local _allowNewInstance = true
local __instance = nil
SilverChampionShipproxy.pvp1List = {}
SilverChampionShipproxy.pvpBattleEnd = {}
SilverChampionShipproxy.confirmHandler = {}

function SilverChampionShipproxy:ctor()
	print("SilverChampionShipproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function SilverChampionShipproxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = SilverChampionShipproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end