RankDataProxy = class("RankDataProxy",function()
	return Model:create("RankDataProxy",{
		uid = 0,
		count = 0,
		association = "无",
		rank_type = 0,
		level = 0,
		name = "",
		role = 1,
	})
end)

local _allowNewInstance = false
local __instance = nil


RankDataProxy.arenarank = {}
RankDataProxy.powerrank = {}
RankDataProxy.playerinfo = {}
RankDataProxy.petteam = {}


function RankDataProxy:ctor()
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function RankDataProxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = RankDataProxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end