AchievementDataProxy = class("AchievementDataProxy", function()
    return Model:create("AchievementDataProxy", {
        current_aid = 0,
        current_sqid = 0,
        current_status = 0
    })
end)

local _allowNewInstance = false
local __instance = nil
AchievementDataProxy.achievementList = {}
AchievementDataProxy.achievementContent = {}
function AchievementDataProxy:ctor()
    print("constructor of AchievementDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function AchievementDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = AchievementDataProxy:new()
        _allowNewInstance = false
    end
    return __instance
end
