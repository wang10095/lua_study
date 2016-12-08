PetBreedProxy = class("PetBreedProxy", function()
    return Model:create("PetBreedProxy", {
        breedType = 0 , --融合类型 普通  特殊 完美
        selectPopupType = 0  -- 选择弹出窗的类型

    })
end)

local _allowNewInstance = false
local __instance = nil

PetBreedProxy.petOrdinaryBreed = {0,0,0,0}
PetBreedProxy.petSpecialBreed = {0,0}
PetBreedProxy.petInherit = {0,0}
PetBreedProxy.addAttributeValue = {}
PetBreedProxy.updateInherit = nil

function PetBreedProxy:ctor()
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function PetBreedProxy:getInstance()
    if (__instance == nil) then
        _allowNewInstance = true
        __instance = PetBreedProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end