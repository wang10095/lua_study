--
-- Author: hapigames
-- Date: 2014-12-03 17:22:57
--
Stagedataproxy = class("Stagedataproxy",function()
	return Model:create("Stagedataproxy",{
		chapter = 0,
		stage = 0,
		starNum = 0,
		normal_or_elite = 0,
		dungeonType = 0,
		remainingtimes = 0,
		bag_prop = 6,
		rewards = {},
		isPopup = false, --是否有弹出窗 
		CapturePetNum = 0, --扫荡扑捉的宠物数量 扑捉一个+1
		startBattle = false,--是否开始战斗  中途退出挑战失败
		})
end)
local _allowNewInstance = false
local __instance = nil
Stagedataproxy.StageList = {}

function Stagedataproxy:ctor()
	print("Stagedataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Stagedataproxy:getInstance()
	if (__instance == nil) then
		print("Stagedataproxy getInstance")
		_allowNewInstance = true
		__instance = Stagedataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end