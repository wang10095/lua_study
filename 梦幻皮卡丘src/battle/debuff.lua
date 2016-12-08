Debuff = class("Debuff")

DEBUFF_TYPES = {
	DAMAGE = 1,
	ATTRIBUTE = 2,
	CONTROL = 3,
}


Debuff.id = 0
Debuff.config = nil
Debuff.rounds = 0 -- 持续回合数
Debuff.maxRounds = 0
Debuff.layers = 0 -- 层数
Debuff.maxLayers = 0
Debuff.type = 0
Debuff.attribId = 0
Debuff.value = 0
Debuff.value_growth = 0
Debuff.percent = 0
Debuff.percent_growth = 0
Debuff.model = 0
Debuff.effect = nil
Debuff.skill_level = 1
Debuff.caster = nil

function Debuff:init(id, caster, skill_level)
	local config = ConfigManager.getDebuffConfig(id)
	if config == nil then
		print("get debuff config fail, id:", id)
		return false
	end
	self.config = config
	self.id = id
	self.type = config.debuff_type
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

function Debuff:create(id, caster, skill_level)
	local ret = Debuff.new()
	if ret:init(id, caster, skill_level) then
		return ret
	end
	return nil
end

function Debuff:getEffect()
	if self.effect == nil then
		print("debuff ---------"..self.model)
		local atlas = string.format(TextureManager.RES_PATH.SPINE_DEBUFF, self.model) .. ".atlas"
	    local json = string.format(TextureManager.RES_PATH.SPINE_DEBUFF, self.model) .. ".json"

	    print("debuff effect", atlas)

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
	
    return self.effect
end

-- 增加叠加数，此操作会刷新回合数
function Debuff:layerUp()
	if self.layers < self.maxLayers then
		self.layers = self.layers + 1
	end
	self.rounds = self.maxRounds
end

function Debuff:cleanup()
	if self.effect then
		self.effect:removeFromParent()
		self.effect:release()
		self.effect = nil
	end
end

function Debuff:getDamage(unitB)
	local unitA = self.caster

	-- if unitB:getHitRage(unitA) * 100 > math.random(100) then
	-- 	return 0
	-- end

	local damage
	local powerCoefficient = ConfigManager.getPetCommonConfig("crit_dodge_coefficient")

	--A的总攻击 ＝ 总攻击固定值＊（1+总攻击百分比）
	-- （A的总普通攻击*A的技能百分比+A的技能附加值）*（1+A的总暴击系数）*B的普通受伤比+A的总穿透伤害
	local attack = unitA and unitA:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK) or 0
	
	local critCoefficient = 0
	local targetDamageRate = 1.0
	-- local penetrateDamage = unitA:getPetAttribute(Constants.PET_ATTRIBUTE.PENETRATE_DAMAGE)

	local targetDamageRate = 1 - unitB:getPetAttribute(Constants.PET_ATTRIBUTE.DAMAGE_REDUCE)

	local skillLevel = self.skill_level - 1
	damage = (attack * (self.percent + self.percent_growth * skillLevel)/100.0 + (self.value + self.value_growth * skillLevel)) * (1 + critCoefficient) * targetDamageRate

	--[[
	-- 计算被动技能对最终结算的影响
	local r = 0
	local passiveSkills = PassiveSkillManager.getPassiveSkills(unitB)
	if passiveSkills then
		for i=1,#passiveSkills do
			r = r + passiveSkills[i]:getFinalReduceValue(unitA, unitB, damage)
		end
	end
	damage = damage - r
	-- ]]
	if not unitA then
		return damage
	end
	return math.ceil(damage * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient")))
end