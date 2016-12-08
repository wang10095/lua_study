PassiveSkill = class("PassiveSkill")

-- 类型（1: 提高自身属性，2:光环，3:条件触发，4: 影响伤害／治疗量结算 ）
-- 类型1: 在计算宠物本身属性的时候使用
-- 类型2: 在战斗过程中计算宠物属性的时候使用 
-- 类型3: 在特定条件触发
-- 类型4: 在计算最终伤害／治疗量时使用
-- 类型2和类型4在战斗开始时通过广播加到己方所有宠物身上，在宠物死亡的时候通过广播移除
PASSIVE_SKILL_TYPES = {
	ATTRIBUTE = 1,
	AURA = 2,
	TRIGGER = 3,
	FINAL = 4,
}

local id_ = 0 -- 每创建一个被动技能实例则id加一作为新实例的id

PassiveSkill.type = 0
PassiveSkill.attribId = 0
PassiveSkill.value = 0
PassiveSkill.value_growth = 0
PassiveSkill.percent = 0
PassiveSkill.percent_growth = 0
PassiveSkill.model = 0
PassiveSkill.effect = nil
PassiveSkill.skill_level = 1

PassiveSkill.skill_id = 0
-- 施法者
PassiveSkill.caster = nil

function PassiveSkill:init(skill_id, caster)
	self.caster = caster
	self.skill_id = skill_id;

	id_ = id_ + 1
	self.id = id_

	if self.caster.monsterId ~= nil then
		self.skill_level = 1
	else
		local formConfig = ConfigManager.getPetFormConfig(self.caster.pet:get("mid"), self.caster.pet:get("form"))
		local idx = 0
		local skillsSize = #formConfig.skills
		local passiveSkillsSize = #formConfig.passive_skills
		for i=1, passiveSkillsSize do
			if formConfig.passive_skills[i] == self.skill_id then
				idx = i + skillsSize
			end
		end
		if idx == 0 then
			print("init passive skill failed, cannot find passive skill index, skill id: " .. skill_id .. ", pet mid: " .. self.caster.pet:get("mid") .. ", form: " .. self.caster.pet:get("form"))
			return false
		end
		self.skill_level = caster.pet:get("skillLevels")[idx]
	end

	if self.skill_level == nil or self.skill_level == 0 then
		print("passive skill locked")
		return false
	end

	local conf  = ConfigManager.getPassiveSkillConfig(self.skill_id)
	if conf then
		self.type = conf.type
		self.attribId = conf.attribId
		self.value = conf.value
		self.value_growth = conf.value_growth
		self.percent = conf.percent
		self.percent_growth = conf.percent_growth
		self.model = conf.model
	else
		print("init passive skill failed, cannot find passive skill config, skill id: " .. skill_id .. ", pet mid: " .. self.caster.pet:get("mid") .. ", form: " .. self.caster.pet:get("form"))
		return false
	end

	local eliminateListener = cc.EventListenerCustom:create("event_unit_act", function(event) 
        self:onUnitAct(event)
    end)
    self.eliminateListener = eliminateListener
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(eliminateListener, 1)

    print("init passive skill", self.skill_id, self.skill_level, self:getValue(), self:getValueBonus())
    return true
end

function PassiveSkill:create(skill_id, caster)
	local ret = PassiveSkill.new()
	if ret:init(skill_id, caster) then
		return ret
	end
	return nil
end

function PassiveSkill:getEffect()

end


function PassiveSkill:getValue(carrier)
	return self.value + self.value_growth * self.skill_level
end

function PassiveSkill:getValueBonus(carrier)
	return math.ceil((self.percent + self.percent_growth * self.skill_level))
end

function PassiveSkill:getPermanentAttr(carrier, attribId)
	if (self.type ~= PASSIVE_SKILL_TYPES.ATTRIBUTE) or self.attribId ~= attribId then
		return 0
	end
	return self:getValue()
end

function PassiveSkill:getPermanentAttrBonus(carrier, attribId)
	if self.type ~= PASSIVE_SKILL_TYPES.ATTRIBUTE or self.attribId ~= attribId then
		return 0
	end
	return self:getValueBonus()
end

-- 光环类buff，检查是否满足条件
function PassiveSkill:check(carrier)
	if self.caster == nil or carrier == nil then
		return false
	end

	local checkFuncs = {}

	-- 泡泡: 使获得护盾的单位攻击提高
	checkFuncs[2] = function(carrier)
		if self.caster ~= carrier then
			return false
		end

		--检查carrier是否有护盾buff，没有则返回0
		local buffs = carrier.buffs
		if buffs then
			for i,buff in ipairs(buffs) do
				if buff.id == 8 then
					return true
				end
			end
		end
		return false
	end

	-- 岩石封闭: HP低于50%后，受到伤害降低20%
	checkFuncs[4] = function(carrier)
		if self.caster ~= carrier then
			return false
		end

		return carrier.curHP < carrier.maxHP * 0.5
	end

	-- HP低于50%时攻击提高30%
	checkFuncs[9] = function(carrier)
	
		if self.caster ~= carrier then
			return false
		end

		return carrier.curHP < carrier.maxHP * 0.5
	end

	-- 诡计: 每次出手都叠加123点攻击
	checkFuncs[10] = function(carrier)
		return self.caster == carrier
	end
	
	-- 使所有友方血量提高123点
	checkFuncs[15] = function(carrier) 
		return (self.caster.isPet == carrier.isPet)
	end

	-- 每有一个队友濒死，都会提高123点攻击力
	checkFuncs[16] = function(carrier)
		return self.caster == carrier
	end

	if checkFuncs[self.skill_id] then
		return checkFuncs[self.skill_id](carrier)
	end

	return false
end

function PassiveSkill:getAttr(carrier, attribId)
	if (self.type ~= PASSIVE_SKILL_TYPES.AURA and self.type ~= PASSIVE_SKILL_TYPES.ATTRIBUTE) or self.attribId ~= attribId then
		return 0
	end
	
	if self:check(carrier) then
		if (self.skill_id == 10) then
			return self:getValue() * self.caster.livedRound
		elseif (self.skill_id == 16) then
			self.powerUpTimes = self.powerUpTimes or 0
			return self:getValue() * self.powerUpTimes
		end
		return self:getValue()
	end

	return 0
end

function PassiveSkill:getAttrBonus(carrier, attribId)
	if (self.type ~= PASSIVE_SKILL_TYPES.AURA and self.type ~= PASSIVE_SKILL_TYPES.ATTRIBUTE) or self.attribId ~= attribId then
		return 0
	end

	if self:check(carrier) then
		if (self.skill_id == 10) then
			return self:getValue() * self.caster.livedRound
		elseif (self.skill_id == 16) then
			self.powerUpTimes = self.powerUpTimes or 0
			return self:getValue() * self.powerUpTimes
		end
		return self:getValueBonus()
	end

	return self:getValueBonus()
end

-- 计算unitA攻击/治疗unitB时对最终伤害/治疗的影响
function PassiveSkill:getFinalReduceValue(unitA, unitB, orig) 
	if self.type ~= PASSIVE_SKILL_TYPES.FINAL then
		return 0
	end

	if self.skill_id == 3 then -- 献身: 同行友方受到伤害时，分摊伤害
		if math.floor((unitB.index - 1)/3) == math.floor((self.caster.index - 1)/3) and unitB ~= self.caster then
			local r = math.floor(orig * self:getValueBonus()/100)
			Utils.dispatchCustomEvent("event_attack_all", {targets={self.caster}, damage=r})
			return r
		end
	elseif self.skill_id == 6 then --牵连 攻击时对血量低于50%的目标额外造成10%伤害
		if (unitA == self.caster) and (unitB.curHP < unitB.maxHP * 0.5) then
			return -orig * getValueBonus()
		end
	end

	return 0
end

function PassiveSkill:getFinalReduceBonus(carrier, orig) 
	if self.type ~= PASSIVE_SKILL_TYPES.FINAL then
		return 0
	end

	return 0
end

function PassiveSkill:getEffect()
	if self.model == 0 then
		return nil
	end
	local atlas = string.format(TextureManager.RES_PATH.SPINE_PASSIVE_SKILL, self.model) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PASSIVE_SKILL, self.model) .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setAnimation(10, "trigger", false)

    return spine
end

function PassiveSkill:onUnitAct(event)

	local action = event._usedata
    local unit = action.unit

    if action.name == "event" then
    elseif action.name == "target_effect" then
    elseif action.name == "hit" then
    	-- 因为battleui在被动技能之前添加事件监听，所以此时应该已经调用过BattleUI:onUnitAct，此时获得宠物的血量为被攻击后的数值
    	if self.skill_id == 1 then		-- 反震:在有防卫卷护盾作用时，对攻击者反射123伤害
    		local effective = false
    		if self.caster.buffs then
    			for i,buff in ipairs(self.caster.buffs) do
    				if buff.id == 9 then
    					effective = true
    					break
    				end
    			end
    		end
    		if effective then
		    	local targets = action.targets
		    	for i,target in ipairs(targets) do
		    		if target == self.caster then
		    			Utils.dispatchCustomEvent("event_attack_all", {targets={unit}, damage=self:getValue()})
		    			return
		    		end
		    	end
	    	end
	    	return
	    end
    elseif action.name == "die" then
    	-- 此时宠物刚执行完攻击/施法动作
    	if self.skill_id == 8 or self.skill_id == 12 then -- 重生： 有一点几率重生，获得10%生命
    		if unit == self.caster and (not unit.reliveTimes or unit.reliveTimes == 0) then
    			local probability = self:getValueBonus()
    			if probability >= math.random(100)  then
    				local effect = self:getEffect()
    				if effect then
    					effect:retain()
					end
    				unit:relive(0.1, effect)
    				unit.reliveTimes = 1
    			end
    		end
    		return
    	end

    	if self.skill_id == 11 and unit == self.caster then	--自爆
    		local effect = self:getEffect()
    		
    		if effect then
    			effect:registerSpineEventHandler(function(event)
    				if event.type == "event" then
						if event.eventData.name == "hit" then
							Utils.dispatchCustomEvent("event_attack_all", {isPet=(not unit.isPet), damage=self:getValue()})
						end
					end
				end)
    			local pos = cc.p(unit.layout:getPosition())
    			Utils.dispatchCustomEvent("event_battle_effect", {effect=effect, pos=pos, time=5.0})
    		end
    		return
    	end

    	if self.skill_id == 16 then
    		if self.caster.isPet == unit.isPet then
    			self.powerUpTimes = self.powerUpTimes or 0
    			self.powerUpTimes = self.powerUpTimes + 1
    		end
    	end

    end
end