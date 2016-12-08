--
-- Author: hapigames
-- Date: 2014-12-15 15:48:15
--
GoldhandDataProxy = class("GoldhandDataProxy", function()
    return Model:create("GoldhandDataProxy", {
        goldremaining = 0,
        diamondremaining = 0,
        goldhandtimes = 0,
        usediamondnum = 0,
        isborrow = 0,
    })
end)

local _allowNewInstance = false
local __instance = nil
GoldhandDataProxy.goldhandList = {}

function GoldhandDataProxy:ctor()
    print("constructor of GoldhandDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function GoldhandDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = GoldhandDataProxy:new()
        _allowNewInstance = false
    end
    return __instance
end