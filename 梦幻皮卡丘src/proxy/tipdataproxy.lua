TipDataProxy = class("TipDataProxy", function()
    return Model:create("TipDataProxy", {
        content = '',
        fontSize = 24,
        color = cc.c3b(0xff, 0, 0xff),
        width = 210,
        bg_margin = 50,
        normal_or_warn = 0 --正常还是警告显示提示框 
    })
end)

local _allowNewInstance = false
local __instance = nil

function TipDataProxy:ctor()
    print("constructor of TipDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function TipDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = TipDataProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end
