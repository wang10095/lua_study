--
-- Author: hapigames
-- Date: 2014-12-15 15:48:15
--

DailyDataProxy = class("DailyDataProxy", function()
    return Model:create("DailyDataProxy", {
        task_id = 0,
        task_state = 0,
        task_times = 0
    })
end)

local _allowNewInstance = false
local __instance = nil
DailyDataProxy.dailyList = {}

function DailyDataProxy:ctor()
    print("constructor of DailyDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function DailyDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = DailyDataProxy:new()
        _allowNewInstance = false
    end
    return __instance
end