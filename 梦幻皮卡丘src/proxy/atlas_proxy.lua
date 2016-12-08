AtlasDataProxy = class("AtlasDataProxy", function()
    return Model:create("AtlasDataProxy", {
        mid = 0,
        form = 0,
        isCollected = false,
    })
end)

local _allowNewInstance = false
local __instance = nil
AtlasDataProxy.atlasList = {}

function AtlasDataProxy:ctor()
    print("constructor of AtlasDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function AtlasDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = AtlasDataProxy:new()
        _allowNewInstance = false
    end
    return __instance
end
