Pet = class("Pet", function()
    return Model:create("Pet", {
        id = 0,
        mid = 0,
        form = 1,
        exp = 0,
        level = 1,
        star = 1,
        aptitude = 1,
        intimacy = 1,
        skillLevels = {}, 
        rank = 1,
        rankPoint = 0,
        character = 1,
        attributeGrowths = {},
        isDirty = true,
        attributes = {},
        growAttributes = {},--成长
        isSelected = 0, --是否被选中
        isEatExp = 0, --是否吃经验药水
        hp = 0,
    })
end
)

function Pet:ctor()
end

function Pet:create()
    return Pet:new()
end

function Pet:update(properties)
    if properties["id"] ~= nil and self:get("id") ~= 0 and properties["id"] ~= self:get("id") then
        return
    end

    for k,v in pairs(properties) do
        self:set(k, v)
    end

    if self:get("star")<=2 then
        self:set("form",1)
    end
    if self:get("star") >= 3 and self:get("star") < 5 and ConfigManager.getPetFormConfig(self:get("mid"), 2) then
        self:set("form",2)
    elseif self:get("star") >= 3 and self:get("star") < 5 and not ConfigManager.getPetFormConfig(self:get("mid"), 2) then
        self:set("form",1)
    end

    if self:get("star") == 5 and ConfigManager.getPetFormConfig(self:get("mid"), 3) then
        self:set("form",3)
    elseif self:get("star") == 5 and not ConfigManager.getPetFormConfig(self:get("mid"), 3) and  ConfigManager.getPetFormConfig(self:get("mid"), 2) then
        self:set("form",2)
    elseif self:get("star") == 5 and not ConfigManager.getPetFormConfig(self:get("mid"), 2) then
        self:set("form",1)
    end
    self:set("isDirty", true)
end

function Pet:getPower()
    -- todo: use the right formula
    local skillSum = 0
    for i,v in ipairs(self:get("skillLevels")) do
        skillSum = skillSum+v
    end
    local HP = ItemManager.getPetAttribute(self,Constants.PET_ATTRIBUTE.HP)
    local DODGE_RATE =  ItemManager.getPetAttribute(self,Constants.PET_ATTRIBUTE.DODGE_RATE)
    local COMMON_ATTACK = ItemManager.getPetAttribute(self,Constants.PET_ATTRIBUTE.COMMON_ATTACK)
    local CRIT = ItemManager.getPetAttribute(self,Constants.PET_ATTRIBUTE.CRIT)
    local CRIT_DAMAGE = ItemManager.getPetAttribute(self,Constants.PET_ATTRIBUTE.CRIT_DAMAGE)
    local power = math.floor(HP/(1-DODGE_RATE)*COMMON_ATTACK*(1+CRIT*(0+CRIT_DAMAGE)/100)/1000+skillSum*10)
    return power
end

function Pet:getAptitudeNum()--获得宠物资质  
    local aptitudeNum = self:get("attributeGrowths")[1]+self:get("attributeGrowths")[2]
    return Utils.roundingOff(aptitudeNum/100)
end

--[[
某项能力值最终值=（基础值+段位提升基础值 +被动技提升基础值+装备提升基础值+成长*等级*该能力系数）*（1+性格提升百分比+装备提升百分比+被动技提升百分比）
--]]
function Pet:updateAttributes()
    local attributes = {}
    local petConfig = ConfigManager.getPetConfig(self:get("mid"))
    local basicAttributes = petConfig["basic_attributes"]
    local trainId = petConfig["train_id"]
    local trainConfig = ConfigManager.getPetTrainConfig(trainId, self:get("rank"), self:get("rankPoint")) 
    local starAttributeGrowths = petConfig["star_attribute_growths"]
    local attributeFactors = ConfigManager.getPetAttributeFactors()
    local CharacterAttibType = ConfigManager.getPetCharacterConfig(self:get("character")).addition_type
    local characterAttrib = {}

    local growAttributes = {}
    for attribKey, attribIndex in pairs(Constants.PET_ATTRIBUTE) do   --7项基础值
        local basicAttrib = basicAttributes[attribIndex] or 0
        local rankAttrib = trainConfig["attributeAddition"][attribIndex] or 0
        local skillAttrib = 0 -- 被动技能相关
        local gearAttrib = 0
        local attribGrowth = 0
        local level = self:get("level")
        local attribFactor = attributeFactors[attribIndex]
        local characterGrowPercent = characterAttrib[attribIndex] or 0 --性格提升百分比
        local gearGrowpPercent = 0
        local skillGrowPercent = 0

        attribGrowth = self:get("attributeGrowths")[attribIndex] or 0
        if starAttributeGrowths[attribIndex] then
            attribGrowth = (attribGrowth + (starAttributeGrowths[attribIndex][self:get("star")] or 0))/100
        end
        growAttributes[attribIndex] = attribGrowth
        local attrib
        if attribIndex == 1 or attribIndex == 2 or attribIndex == 6 then
            attrib = (basicAttrib + rankAttrib + skillAttrib + gearAttrib + attribGrowth * level * attribFactor)
        else
            attrib = basicAttrib
        end
       
        attributes[attribIndex] = attrib
    end
    self:set("attributes", attributes)
    self:set("growAttributes",growAttributes)
end

-- 属性固定值部分
function Pet:getBasicAttribute(attributeId)
    if self:get("isDirty") then
        self:updateAttributes()
    end
    if attributeId == Constants.PET_ATTRIBUTE.DAMAGE_REDUCE then
        return 0
    end

    -- 性格影响的是暴击率和闪避率
    if attributeId == Constants.PET_ATTRIBUTE.CRIT_RATE or attributeId == Constants.PET_ATTRIBUTE.DODGE_RATE then
        local characterFactors = ConfigManager.getPetCharacterConfig(self:get("character"))
        for i,v in ipairs(characterFactors.addition_type) do
            if v == attributeId then
                characterFactor = characterFactors.addition_percent[i]
                return self:get("attributes")[attributeId] + characterFactor
            end   
        end
    end
    return self:get("attributes")[attributeId]
end

-- 属性加成百分比
function Pet:getAttributeBonus(attributeId)
    -- 性格影响的是暴击率和闪避率

    local characterFactor = 0
    local gearFactor = 0
    local skillFactor = 0
    
    if attributeId ~= Constants.PET_ATTRIBUTE.CRIT_RATE and attributeId ~= Constants.PET_ATTRIBUTE.DODGE_RATE then
        local characterFactors = ConfigManager.getPetCharacterConfig(self:get("character"))
        Debug.simplePrintTable(characterFactors)
        -- print(attributeId)
        for i,v in ipairs(characterFactors.addition_type) do
            if v == attributeId then
                characterFactor = characterFactors.addition_percent[i]
                -- print("getAttributeBonus", attributeId, characterFactor)
                break
            end   
        end
    end
    return characterFactor
end

function Pet:getAttribute(attributeId)
    -- print(attributeId)
    return self:getBasicAttribute(attributeId) * (1 + self:getAttributeBonus(attributeId))
end

function Pet:GetgrowAttribute(attributeId)
    if self:get("isDirty") then
        self:updateAttributes()
    end 
    return self:get("growAttributes")[attributeId]
end

function Pet:copyProperty(pet)
    
end
