StoryProxy = class("StoryProxy", function()
    return Model:create("StoryProxy", {
        storyType = 1, --剧情类型   1  为view   2 为chapter
        isShow = 0,
    })
end)

StoryProxy.storyConfig = nil
StoryProxy.callback = nil

local _allowNewInstance = false
local __instance = nil

function StoryProxy:ctor()
    print("constructor of StoryProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function StoryProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = StoryProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end
