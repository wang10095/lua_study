Buff = class("Buff")

BUFF_TYPES = {
	HEAL = 1,
	ATTRIBUTE = 2,
	ABSORB_DAMAGE = 3,
	REFLECT_DAMAGE = 4,
}

Buff.id = 0
Buff.config = nil
Buff.rounds = 0 -- 持续回合数
Buff.maxRounds = 0
Buff.layers = 0 -- 层数
Buff.maxLayers = 0
Buff.type = 0
Buff.attribId = 0
Buff.value = 0
Buff.value_growth = 0
Buff.percent = 0
Buff.percent_growth = 0
Buff.model = 0
Buff.effect = nil
Buff.skill_level = 1
Buff.caster = nil

function Buff:init(id, caster, skill_level)
	local config = ConfigManager.getBuffConfig(id)
	if config == nil then
		print("fail to get buff config: ", id)
		return false
	end
	self.id = id
	self.type = config.buff_type
	self.maxRounds = config.rounds
	self.rounds = config.rounds
	self.maxLayers = config.layers
	self.layers = 1
	self.attribId = config.attribId
	self.value = config.value
	self.value_growth = config.value_growth
	self.percent = config.percent
	self.percent_growth = config.percent_growth
	self.model = config.model
	self.skill_level = skill_level
	self.caster = caster
	return true
end

function Buff:create(id, caster, skill_level)
	local ret = Buff.new()
	if ret:init(id, caster, skill_level) then
		return ret
	end
	return nil
end

function Buff:getEffect()
	if self.effect == nil then
		
		local atlas = string.format(TextureManager.RES_PATH.SPINE_BUFF, self.model) .. ".atlas"
	    local json = string.format(TextureManager.RES_PATH.SPINE_BUFF, self.model) .. ".json"

	    if not cc.FileUtils:getInstance():isFileExist(atlas) then
	    	return nil
	    end

	    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	    spine:registerSpineEventHandler(function(event)
			if event.type == "complete" and event.animation == "trigger" then
				spine:removeFromParent()
			end
		end)
	    spine:retain()
	    self.effect = spine
	end
	if self.effect:setAnimation(0, "last", true) ~= 1 then
		self.effect:setAnimation(0, "trigger", false)
	end

	print("get buff effect", self.id, tostring(self.effect))
    return self.effect
end

-- 增加叠加数，此操作会刷新回合数
function Buff:layerUp(caster)
	print("buff layer up", self.id, self.rounds)
	if self.layers < self.maxLayers then
		self.layers = self.layers + 1
	end
	-- if self.absorbDamage ~= nil then
		self.absorbDamage = self:calcAbsorbDamage(self.caster)
		self.reflectionDamage = self:calcReflectionDamage(self.caster)
	-- end
	self.rounds = self.maxRounds
end

function Buff:cleanup()
	print("buff clean up", self.id, tostring(self.effect))
	if self.effect then
		self.effect:removeFromParent()
		self.effect:release()
		self.effect = nil
	end
end

function Buff:getHeal(unitB)
	if self.type ~= BUFF_TYPES.HEAL then
		return 0
	end
	
	local unitA = self.caster
	--（A的总普通攻击*A的技能百分比+A的技能附加值）*（1+A的总暴击系数）
	local attack = unitA:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
	local critDamage = unitA.pet:getBasicAttribute(Constants.PET_ATTRIBUTE.CRIT_DAMAGE)
	local basicCritDamage = ConfigManager.getPetCommonConfig("basic_crit_damage")
	critCoefficient = (critDamage + basicCritDamage)/100.0

	local skillLevel = self.skill_level - 1
	local heal = (attack * (self.percent + self.percent_growth * skillLevel)/100.0 + (self.value + self.value_growth * skillLevel)) * (1 + critCoefficient)

	return math.ceil(heal * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient")))
end

-- 吸收值＝攻击＊百分比 ＋ 固定值
function Buff:calcAbsorbDamage(unitB)
	if self.type ~= BUFF_TYPES.ABSORB_DAMAGE then
		return 0
	end

	local attack = unitB:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
	local skillLevel = self.skill_level - 1
	return math.ceil(attack * (self.percent + self.percent_growth * skillLevel)/100.0 + (self.value + self.value_growth * skillLevel))
end

function Buff:getAbsorb(unitB)
	if self.type ~= BUFF_TYPES.ABSORB_DAMAGE then
		return 0
	end
	if self.absorbDamage == nil then
		self.absorbDamage = self:calcAbsorbDamage(unitB)
	end
	return self.absorbDamage
end

-- 反射值＝攻击＊百分比 ＋ 固定值
function Buff:calcReflectionDamage(unitB)
	if self.type ~= BUFF_TYPES.REFLECT_DAMAGE then
		return 0
	end

	local attack = unitB:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
	local skillLevel = self.skill_level - 1
	return math.ceil(attack * (self.percent + self.percent_growth * skillLevel)/100.0 + (self.value + self.value_growth * skillLevel))
end

function Buff:getReflection(unitB)
	if self.type ~= BUFF_TYPES.REFLECT_DAMAGE then
		return 0
	end
	if self.reflectionDamage == nil then
		self.reflectionDamage = self:calcReflectionDamage(unitB)
	end
	return self.reflectionDamage
end

