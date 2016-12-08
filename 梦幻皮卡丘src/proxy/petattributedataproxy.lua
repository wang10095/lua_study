PetAttributeDataProxy = class("PetAttributeDataProxy", function()
    return Model:create("PetAttributeDataProxy", {
        sift = 0, --筛选
        sequence = '', -- 排序
        eatExp = false,
        new = 0,
        growAttributes = {},
        rankAttributes = {},
        buyedCount = 0,
        skillType = 0,
        useExpItem = 1, --exp  mid
        isPopup = false, --有没有弹框出现  筛选 排序
        isDrop = false,
        dropStage = 0,
        isPassiveSkill = false,
        skillLevel = 0,
    })
end)

PetAttributeDataProxy.newPetsTable = {} --将捕获的宠物id 存放进来  查看宠物信息时删除
PetAttributeDataProxy.updateSkill = {}

local _allowNewInstance = false
local __instance = nil

function PetAttributeDataProxy:ctor()
    print("constructor of PetAttributeDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function PetAttributeDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = PetAttributeDataProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end
