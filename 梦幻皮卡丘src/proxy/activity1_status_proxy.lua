Activity1StatusProxy = class("Activity1StatusProxy", function()
    return Model:create("Activity1StatusProxy", {
        grid = 0,
        diceCount = 0,
        score = 0,
        remainTimes = 0,
        rewardTimes = 0,
        diceEvent = 0,
        ernie_id = 0,
        token = 0,
        qid = {},
        difficulty = 0,
        activity1Mark = 0,
        activity1Type = 0,
        pid = "",
    })
end)

local _allowNewInstance = false
local __instance = nil
Activity1StatusProxy.activity1statusData = {}
Activity1StatusProxy.rewardTable = {}

function Activity1StatusProxy:ctor()
    print("constructor of Activity1StatusProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function Activity1StatusProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = Activity1StatusProxy:new()
        _allowNewInstance = false
    end
    return __instance
end
