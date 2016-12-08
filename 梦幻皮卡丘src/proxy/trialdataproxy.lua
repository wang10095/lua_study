TrialDataProxy = class("TrialDataProxy", function()
    return Model:create("TrialDataProxy", {
        currentStorey = 0,
        historyMaxStorey = 0,
        remainingResetTimes = 0,
        remainingSweepTime = 0 -- -1 for inactive
    })
end)

local _allowNewInstance = false
local __instance = nil
TrialDataProxy.treasureList = {}

function TrialDataProxy:ctor()
    print("constructor of TrialDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function TrialDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = TrialDataProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end