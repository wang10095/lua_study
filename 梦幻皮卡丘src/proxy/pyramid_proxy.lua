PyramidProxy = class("PyramidProxy", function()
    return Model:create("PyramidProxy", {
        has_reward = 0, -- 0 为不用领取 1 为需要领取
        reset_has_reward  = 1, --1 为不用领取  0 为需要领取
        floor = 0,
    })
end)

local _allowNewInstance = false
local __instance = nil

PyramidProxy.petHpList = {}
PyramidProxy.point = nil

function PyramidProxy:updatePetHp(petList)  -- {{1,234},{43,123},...} 更新宠物血量
    for i,v in ipairs(petList) do
        for j,m in ipairs(petHpList) do
            if v[1] == j[1] then
                v[2] = m[2]
            end
        end
    end
end



function PyramidProxy:ctor()
    print("constructor of PyramidProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function PyramidProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = PyramidProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end
