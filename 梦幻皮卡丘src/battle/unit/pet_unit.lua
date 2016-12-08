PetUnit = class("PetUnit")

local PET_UNIT_STATUS = {
	INIT = 0,
	IDLE = 1,
	ACTIVE = 2,
	DEAD = 3,
}

local ANIM_TYPE = {
	PET = 1,
	BALL = 2,
	SKILL = 3,
	TARGET = 4,
	ACTION = 5,
}

local ACTION_STATUS = {
	BREATH = 1,
	CAST = 2,
	MOVE = 3,
	ATTACK = 4,
	MOVE_BACK = 5
}

local BUFF_DEBUFF_LAYOUT_TAG = 100

PetUnit.layout = nil
PetUnit.shadow = nil
PetUnit.pet = nil
PetUnit.spine = nil
PetUnit.attackEffects = nil
PetUnit.targetEffects = nil
PetUnit.actionEffects = nil
PetUnit.ballSpine = nil
PetUnit.maxHP = 0
PetUnit.curHP = 0
PetUnit.status = PET_UNIT_STATUS.INIT
PetUnit.isLeading = true --是否先手
PetUnit.index = 0
PetUnit.power = 0
PetUnit.targets = nil
PetUnit.isPet = true
PetUnit.isBoss = false
PetUnit.partnerTargets = nil
PetUnit.enemyTargets = nil
PetUnit.demonMid = nil
PetUnit.origPosition = nil
PetUnit.buffs = nil
PetUnit.debuffs = nil
PetUnit.eventListeners = {}
PetUnit.changeToBall = false
PetUnit.lastAttackedDamage = 0 --最后一次被攻击受到的伤害值
PetUnit.actionStatus = ACTION_STATUS.BREATH
PetUnit.SuperDreamSpine = 0
PetUnit.livedRound = 0 --已存活回合数，用于计算怪物技能id
PetUnit.effectIndex = 0
function PetUnit:start()
	if self.isPet then
		if self.ballSpine == nil then
			local atlas = TextureManager.RES_PATH.SPINE_SPRITE_BALL .. ".atlas"
		    local json = TextureManager.RES_PATH.SPINE_SPRITE_BALL .. ".json"
			local ballSpine = sp.SkeletonAnimation:create(json, atlas, 1)
			ballSpine:setTimeScale(BattleUI.getAnimSpeed())
			ballSpine:retain()
			ballSpine:setPosition(cc.p(50, 0))
			print("2")
			ballSpine:registerSpineEventHandler(function(event)
				if event.type == 'event' and event.eventData.name == 'get_out' then
					self.spine:setOpacity(255)
					self.spine:setAnimation(ANIM_TYPE.PET, "emerge", false)
					self.spine:addAnimation(ANIM_TYPE.PET, "breath", true, 0.5)
					self.actionStatus = ACTION_STATUS.BREATH
					ballSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function()
						self.ballSpine:removeFromParent()
						self.ballSpine:release()
						self.ballSpine = nil
					end)))
		        end
			end)
			self.ballSpine = ballSpine
		end

		self.layout:addChild(self.ballSpine)

		self.ballSpine:setAnimation(ANIM_TYPE.BALL, "start", false)
		self.spine:setOpacity(0)
		
		self.shadow:setVisible(false)
		self.shadow:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			self.shadow:setVisible(true)
		end)))

	else
		local sp = self.spine
		local targetPos = cc.p(sp:getPosition())
		local startPos = cc.p(targetPos.x + 200, targetPos.y)
		sp:setPosition(targetPos)
		sp:setAnimation(ANIM_TYPE.PET, "breath", true)
		self.actionStatus = ACTION_STATUS.BREATH
		
		-- sp:setPosition(startPos)
		-- sp:setAnimation(ANIM_TYPE.PET, "walk", true)
		-- sp:addAnimation(ANIM_TYPE.PET, "breath", true, 0.5)
		-- sp:runAction(cc.MoveTo:create(0.5, targetPos))
	end
	-- self.shadow:setVisible(false)
	-- self.shadow:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
	-- 	self.shadow:setVisible(true)
	-- end)))
end

function PetUnit:getPowerLevel()
	if self.curHP <= 0 then
		return 1
	end
	local power_section = ConfigManager.getPetConfig(self.pet:get("mid")).skill_energy_part
	if self.power >= power_section[1] then
		return 2
	-- elseif self.power > 33 and self.power <= 66 then
	-- 	return 2
	else
		return 1
	end
end

function PetUnit:getValidSkillIndex(powerLevel)
	if self.monsterId then
		local skillConfig = self:getSkillConfig()
		return skillConfig.index
	else
		local level = powerLevel or self:getPowerLevel()
		local formConfig = ConfigManager.getPetFormConfig(self.pet:get("mid"), self.pet:get("form"))
		local skills = formConfig.skills
		if #skills <= level then
			return #skills
		else
			return level
		end
	end
end

function PetUnit:getSkillAnimName(anim)
	local skillIndex = self:getValidSkillIndex()
	if skillIndex == 0 then
		return nil
	end
	-- print("skill"..skillIndex.."_"..anim)  
	return "skill"..skillIndex.."_"..anim
end

function PetUnit:getSkillConfig()
	local skillId = 0
	local ret = nil

	if self.monsterId then
		local monsterConfig = ConfigManager.getMonsterConfig(self.monsterId)
		local skills = monsterConfig.skills;
		Debug.simplePrintTable(monsterConfig)
		-- 通过回合数判断当前技能
		local r = self.livedRound % (#skills) + 1;
		skillId = skills[r]
		-- skillId = monsterConfig.skills
		ret = ConfigManager.getSkillConfig(skillId)
		-- print("get skill config of id", skillId)
		-- 怪物需要根据配置重新设置技能等级
		-- 补充：全为1级
		local skillLevels = {}
		skillLevels[ret.index] = 1
		self.pet:set("skillLevels", skillLevels)
	else
		if self.curHP <= 0 then
			return ConfigManager.getSkillConfig(0)
		else
			local skillIndex = self:getValidSkillIndex()
			if skillIndex == 0 then
				return nil
			end
			skillId = ConfigManager.getPetFormConfig(self.pet:get("mid"), self.pet:get("form")).skills[skillIndex]
			ret = ConfigManager.getSkillConfig(skillId)
		end
	end

	-- print("skillId = "..skillId)
	return ret
end

-- self为被攻击对象
function PetUnit:getDamage(unitA)
	-- do
	-- 	return 0
	-- end
	-- local level = self:getPowerLevel()
	-- if level == 3 then
	-- 	return 50
	-- elseif level == 2 then
	-- 	return 25
	-- else
	-- 	return 5
	-- end
	local isCrit = ((unitA:getFinalCritRate(self) * 100 > math.random(100)) and true) or false --* 100 > math.random(100)
	return self:getFinalCommonDamage(unitA, isCrit),isCrit
end

function PetUnit:getHeal(unitA)
	local isCrit = ((unitA:getFinalCritRate(self) * 100 > math.random(100)) and true) or false --* 100 > math.random(100)
	return self:getFinalCommonHeal(unitA, isCrit), isCrit --+ self:getFinalSpecialHeal(unitA)
end

function PetUnit:findTargets(petUnits, demonUnits)
	self.partnerTargets = {}
	self.enemyTargets = {}

	local pTargets = nil
	local eTargets = nil
	if self.isPet then
		eTargets = demonUnits
		pTargets = petUnits
	else
		eTargets = petUnits
		pTargets = demonUnits
	end
	-- 默认目标
	local function findDefaultTarget(col, r, tb)
		for i=0,2 do
			if col > 1 then
				i = -i
			end
			local c = (col + i - 1) % 3 + 1
			local t = tb[r * 3 + c]
			if t ~= nil and t:isAvailable() then
				return t
			end
		end
		return nil
	end

	-- 根据技能寻找目标
	--[[
		1	默认
		2	随机
		3	自己
		4	默认行
		5	随机行
		6	前列
		7	后列
		8	随机列
		9	血量百分比最低
		10	全体
	--]]
	local function findSkillTarget(methodId, targetNum, fromTb)
		print("find targets:", methodId, targetNum)
		local targetIdxes = ""
		for i = 1, 6 do
			v = fromTb[i]
			if v then
				targetIdxes = targetIdxes .. v.index .. "  "
			end
		end

		-- print("from: ", targetIdxes)

		if fromTb == nil then
			return {}
		end

		local ret = {}
		local targetMethods = {}

		targetMethods[1] = function()
			for i=0,1 do
				local col = (self.index - 1)%3 + 1
				local t = findDefaultTarget(col, i, fromTb)
				if t ~= nil then
					table.insert(ret, t)
					break
				end
			end
		end
		targetMethods[2] = function()
			local tmp = {}
			for i=1, 6 do
				if fromTb[i] ~= nil and fromTb[i]:isAvailable() then
					table.insert(tmp, fromTb[i])
				end
			end
			targetNum = (targetNum < #tmp) and targetNum or #tmp
			local i = 0
			while targetNum > 0 do
				local r = math.random(#tmp - i)
				if tmp[r] then
					table.insert(ret, tmp[r])	
				end
				table.remove(tmp, r)
				targetNum = targetNum - 1
			end
		end
		targetMethods[3] = function()
			table.insert(ret, self)
		end
		targetMethods[4] = function()
			local col = (self.index - 1)%3 + 1
			local t = findDefaultTarget(col, 0, fromTb)
			if t and t:isAvailable() then
				table.insert(ret, t)
				if fromTb[t.index + 3] and fromTb[t.index + 3]:isAvailable() then
					table.insert(ret, fromTb[t.index + 3])
				end
			else
				t = findDefaultTarget(col, 1, fromTb)
				if t and t:isAvailable() then
					table.insert(ret, t)
				end
			end
		end
		targetMethods[5] = function()
			local r = math.random(3)
			local t = findDefaultTarget(r, 0, fromTb)
			if t and t:isAvailable() then
				table.insert(ret, t)
				if fromTb[t.index + 3] and fromTb[t.index + 3]:isAvailable() then
					table.insert(ret, fromTb[t.index + 3])
				end
			else
				t = findDefaultTarget(r, 1, fromTb)
				if t and t:isAvailable() then
					table.insert(ret, t)
				end
			end
		end
		targetMethods[6] = function()
			for i=1,3 do
				if fromTb[i] and fromTb[i]:isAvailable() then
					table.insert(ret, fromTb[i])
				end
			end
			if #ret == 0 then
				for i=4,6 do
					if fromTb[i] and fromTb[i]:isAvailable() then
						table.insert(ret, fromTb[i])
					end
				end
			end
		end
		targetMethods[7] = function()
			for i=4,6 do
				if fromTb[i] and fromTb[i]:isAvailable() then
					table.insert(ret, fromTb[i])
				end
			end
			if #ret == 0 then
				for i=1,3 do
					if fromTb[i] and fromTb[i]:isAvailable() then
						table.insert(ret, fromTb[i])
					end
				end
			end
		end
		targetMethods[8] = function()
			local r = math.random(2)
			for i=r * 1, r * 3 do
				if fromTb[i] and fromTb[i]:isAvailable() then
					table.insert(ret, fromTb[i])
				end
			end
			if #ret == 0 then
				r = r%2 + 1
				for i=r * 1, r * 3 do
					if fromTb[i] and fromTb[i]:isAvailable() then
						table.insert(ret, fromTb[i])
					end
				end
			end
		end
		
		targetMethods[9] = function()
			for i = 1, 6 do
				if fromTb[i] and fromTb[i]:isAvailable() then
					local hpRate = fromTb[i].curHP * 1.0 / fromTb[i].maxHP
					for j = 1, targetNum do
						if ret[j] == nil or hpRate < ret[j].curHP * 1.0 / ret[j].maxHP then
							table.insert(ret, j, fromTb[i])
							if #ret > targetNum then
								table.remove(ret)
							end
							break
						end
					end
				end
			end
		end
		
		targetMethods[10] = function()
			for i,v in pairs(fromTb) do
				if fromTb[i] and fromTb[i]:isAvailable() then
					table.insert(ret, v)
				end
			end
		end

		local method = targetMethods[methodId] or targetMethods[1]
		method()
 
 		targetIdxes = ""
		for i,v in ipairs(ret) do
			targetIdxes = targetIdxes .. v.index .. "  "
		end

		-- print("result: ", targetIdxes)

		return ret
	end

	local skillConfig = self:getSkillConfig()
	local targetNum = skillConfig.target_num
	if type(targetNum) == "table" then
		local t1 = targetNum[1]
		local t2 = targetNum[2]
		targetNum = math.random(t1, t2)
	end

	if skillConfig.skill_type == 1 then
		self.enemyTargets = findSkillTarget(skillConfig.target_method, targetNum, eTargets)
		-- print(#self.enemyTargets)
		return self.enemyTargets 
	else
		self.partnerTargets = findSkillTarget(skillConfig.target_method, targetNum, pTargets)
		return self.partnerTargets 
	end
end

function PetUnit:activate()
	if self.spine == nil then
		return false
	end
	self.damage = 0
	self.effectIndex = 0
	self.status = PET_UNIT_STATUS.ACTIVE
	self.layout:setLocalZOrder(100)
	print(" ***********************************   "..self:getSkillConfig().id)
	print( " "..self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("cast"), false) )
	if self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("cast"), false) ~= 1 then
		self:finishCast()
	end
	self.actionStatus = ACTION_STATUS.CAST
	MusicManager.playSkillSoundEffect(self:getSkillConfig().id)
	if self.isPet and self:isDead() then
		MusicManager.playSkillSoundEffect(0)
	end
	return true
end

function PetUnit:finishCast()
	-- todo 多目标移动到战场中央
	self:moveToTarget()
	print("55555")
end

function PetUnit:moveToTarget()
	local targetPos
	local method = self:getSkillConfig().target_method
	print("method = "..method)
	if self:getSkillConfig().id == 90 then
		MusicManager.chest_hit()
	end
	if method == 4 or method == 5 then --默认或随机行
		local first = self.enemyTargets[1]
		targetPos = cc.p(first.layout:getPosition())
		if first.index > 3 then
			targetPos.x = self.isPet and (targetPos.x - 132) or (targetPos.x + 132)
		end
	elseif method == 10 then --全体
		if not self.isPet then
			targetPos = cc.p(160,620)
		else
			targetPos = cc.p(550,620)
		end
	elseif method == 3 then  --自己

		targetPos = cc.p(self.layout:getPosition())

	elseif method == 6 then --前列
		if not self.isPet and self:getSkillConfig().effect_move_method == 5 then
			targetPos = cc.p(240,600)
		else
			targetPos = cc.p(480,600)
		end

	elseif method == 7 then --后列
		if not self.isPet then
			targetPos = cc.p(160,600)
		else
			targetPos = cc.p(530,600)
		end
	elseif #self.enemyTargets == 1 then

		targetPos = cc.p(self.enemyTargets[1].layout:getPosition())

	end
	-- print("targets "..targetPos.x ..""..targetPos.y)
	if targetPos ~= nil then
		
		local offset = 80
		-- if self.isPet and self.pet:get("mid") == 2 then
		-- 	offset = 120
		-- end
		targetPos.x = self.isPet and (targetPos.x - offset) or (targetPos.x + offset)
		if self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("move"), false) == 1 then
			self.actionStatus = ACTION_STATUS.MOVE
			self.origPosition = cc.p(self.layout:getPosition())
			self.layout:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, targetPos), cc.CallFunc:create(function()
				self:attack()
			end)))
		elseif self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("attack"), false) == 1 then
			self.actionStatus = ACTION_STATUS.ATTACK
			self.layout:setPosition(targetPos)
		else
			self:finish()
		end
	else
		self:finish()
	end
end

function PetUnit:attack()
	if not self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("attack"), false) then
		self:moveBack()
	end
	self.actionStatus = ACTION_STATUS.ATTACK
end

function PetUnit:moveBack()
	self.spine:setAnimation(ANIM_TYPE.PET, "move", false)
	self.actionStatus = ACTION_STATUS.MOVE_BACK
	self.layout:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, self.origPosition), cc.CallFunc:create(function()
		self:finish()
	end)))
end

function PetUnit:finishMoveBack()
end

function PetUnit:finish()
	self.layout:setLocalZOrder(self.index)
	self.spine:setAnimation(ANIM_TYPE.PET, "breath", true)
	self.actionStatus = ACTION_STATUS.BREATH
	print("66666")
end

function PetUnit:startAttackEffect(spine, target)
	local pos = cc.p(self.layout:getPosition())
	local targetPos = cc.p(target.layout:getPosition())

	if self.model ~= 120 then
		pos.y = pos.y + 40
	end
	-- 1 从施法者飞向目标
	-- 2 从天上飞向目标
	-- 3 从施法者连接目标
	-- 4 原地消失，出现在目标出
	-- 5 出现在固定位置
	local skillConfig = self:getSkillConfig()
	local skillMoveMethod = skillConfig.effect_move_method
	print(" skillId = "..skillConfig.id ,"skillMoveMethod = "..skillMoveMethod)
	if skillMoveMethod == 3 then
		local angle = -Utils.getAngle(pos, targetPos)
		local dist = cc.pGetDistance(targetPos, pos)
		local scale = dist/320
		if not self.isPet then
			scale = -scale
			angle = angle - 180
		end
		
		local offset = 40 * math.sin(angle * 3.1415 / 180)
		pos.x = pos.x - offset
		targetPos.x = targetPos.x - offset

		spine:setPosition(pos)
		spine:setScaleX(scale)
		spine:setRotation(angle)
		spine:setAnimation(ANIM_TYPE.SKILL, "part1", false)
		spine:runAction(cc.Sequence:create(cc.DelayTime:create(2.3), cc.CallFunc:create(function()
			spine:removeFromParent()
		end)))
	elseif skillMoveMethod == 1 then
		-- pos.y = pos.y + 40
		-- pos.x = pos.x + 40
		targetPos.y = targetPos.y + 40
		local angle = -Utils.getAngle(pos, targetPos)
		local dist = cc.pGetDistance(targetPos, pos)
		spine:setRotation(angle)
		spine:setPosition(pos)
		
		spine:setAnimation(ANIM_TYPE.SKILL, "part1", false)
	
		spine:runAction(cc.Sequence:create(
			cc.MoveTo:create(dist/1000, cc.p(targetPos.x, targetPos.y + 40)), 
			cc.CallFunc:create(function()
				spine:setRotation(0)
				spine:setPosition(cc.p(targetPos.x, targetPos.y - 40))
				spine:setAnimation(ANIM_TYPE.SKILL, "part2", false)
			end), 
			cc.DelayTime:create(1.0), 
			cc.CallFunc:create(function()
				spine:removeFromParent()
			end))
		)
	elseif skillMoveMethod == 5 then
		-- local angle = -Utils.getAngle(pos, targetPos)
		-- local dist = cc.pGetDistance(targetPos, pos)
		-- spine:setRotation(angle)

		-- todo 优化，用一个表维护id和位置的映射
		if self.isPet then
			if skillConfig.id == 63 then
				spine:setPosition(cc.p(500, 620))
			elseif skillConfig.id == 75 or skillConfig.id == 76 then --菊草叶
				spine:setPosition(cc.p(140, 620))
			elseif skillConfig.id == 72 then  --杰尼龟
				spine:setPosition(cc.p(450, 620))
			elseif skillConfig.id == 36 then   --乱叶飞舞
				spine:setPosition(cc.p(480, 620))
			elseif skillConfig.id == 37 then   --泡沫光线
				spine:setPosition(cc.p(300, 620))
			else
				spine:setPosition(cc.p(480, 620))
			end
		else
			if skillConfig.id == 63 then     --妙蛙花
				spine:setPosition(cc.p(170, 620))
			elseif skillConfig.id == 75 or skillConfig.id == 76  then --菊草叶
				spine:setPosition(cc.p(580, 620))
			elseif skillConfig.id == 72 then  --杰尼龟
				spine:setPosition(cc.p(250, 620))
			elseif skillConfig.id == 36 then   --乱叶飞舞
				spine:setPosition(cc.p(200, 620))
			elseif skillConfig.id == 37 then   --泡沫光线
				spine:setPosition(cc.p(300, 620))
			else
				spine:setPosition(cc.p(230, 620))
			end
			spine:setScaleX(-1)
		end
		
		spine:setAnimation(ANIM_TYPE.SKILL, "part1", false)
	
		spine:runAction(cc.Sequence:create(cc.DelayTime:create(2.3), cc.CallFunc:create(function()
			spine:removeFromParent()
		end)))
	elseif skillMoveMethod == 6 then

		spine:setPosition(cc.p(330, 640))
		spine:setScaleX(-1)
		spine:setAnimation(ANIM_TYPE.SKILL, "part1", false)
		spine:addAnimation(ANIM_TYPE.SKILL, "part2", true)
		self.SuperDreamSpine = 1
		local listener = cc.EventListenerCustom:create("remove_superdream_spine", function ( )
			-- spine:setAnimation(ANIM_TYPE.SKILL, "part3", false)
			spine:removeFromParent()
			self.SuperDreamSpine = nil
		end)
   		local dispatcher = cc.Director:getInstance():getEventDispatcher()
    	dispatcher:addEventListenerWithFixedPriority(listener, 1)
	end
end

function PetUnit:getAttackEffects()    --获得攻击特效
	print("get skill effect", self.model,self:getValidSkillIndex(),self.index, self:getSkillConfig().id,self:getSkillConfig().buff_id)
	local function createEffect(target, i)
		local skillConfig = ConfigManager.getEffectConfig(self.model, self:getValidSkillIndex())
 		if skillConfig.skill_id ~= 0 then
 			print("skill 特效 ")
			local key = "spine/spine_skill_effect/"..skillConfig.skill_id
			local spine = SpineCache:getInstance():getSpine(key, (i > 1))
			if spine then
				spine:removeFromParent()
			else
				local atlas = "spine/spine_skill_effect/"..skillConfig.skill_id..".atlas"
				local json = "spine/spine_skill_effect/"..skillConfig.skill_id..".json"
				spine = sp.SkeletonAnimation:create(json, atlas, skillConfig.skill_scale)
			end
			spine:setTimeScale(BattleUI.getAnimSpeed())
			print("3")
			spine:registerSpineEventHandler(function(event)
				if event.type == "complete" and event.trackIndex == ANIM_TYPE.SKILL then
					if event.animation == self:getSkillAnimName("part1") then
						if not spine:setAnimation(ANIM_TYPE.SKILL, self:getSkillAnimName("part2"), false) then
							spine:removeFromParent()
						end
					end
				elseif event.type == "event" then
					print("dispatch skill effect event: ", event.eventData.name, tostring(spine), self.isPet, self.index, self:getSkillConfig().id)
					local customEvent = cc.EventCustom:new("event_unit_act")
					customEvent._usedata = {name=event.eventData.name, unit=self}
					-- if event.eventData.name == "hit" or event.eventData.name == "target_effect" then
					-- 	if self:getSkillConfig().effect_move_method == 5 then
					-- 		customEvent._usedata.targets = nil
					-- 	else
					-- 		customEvent._usedata.targets = {target}
					-- 	end
					-- end
					if event.eventData.name == "hit" then
						if self:getSkillConfig().effect_move_method == 5 then
							customEvent._usedata.targets = self.enemyTargets
						else
							customEvent._usedata.targets = {target}
						end
					end
					cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
				end
			end)
			
			self:startAttackEffect(spine, target)
			return spine
		end
	end
	self.attackEffects = {}

	local targets
	local skillType = self:getSkillConfig().skill_type
	if skillType == 1 then
		targets = self.enemyTargets
	else
		targets = self.partnerTargets
	end
	
	if self:getSkillConfig().effect_move_method == 5 then
		for i,t in ipairs(targets) do
			if i == 1 then
				local spine = createEffect(t, i)
				table.insert(self.attackEffects, spine)
			end
		end
	else
		for i,t in ipairs(targets) do
			local spine = createEffect(t, i)
			table.insert(self.attackEffects, spine)
		end
	end

	print("skill amount = "..#self.attackEffects)
	return self.attackEffects
end

function PetUnit:getTargetEffects(targets)    --获得目标特效
	print("get target effect", self.index, self:getSkillConfig().id)

	function createEffect(target, i)
		
		if self:getSkillConfig().effect_move_method == 3 and self.effectIndex > 1 then 
			return 
		end
		local targetConfig = ConfigManager.getEffectConfig(self.model, self:getValidSkillIndex())
		print(self.model.." ^^^^^^^^^^^ "..targetConfig.target_id)
		local key = "spine/spine_target_effect/"..targetConfig.target_id
		local spine = SpineCache:getInstance():getSpine(key, (i > 1))
		if spine then
			spine:removeFromParent()
		else
			local atlas = "spine/spine_target_effect/"..targetConfig.target_id..".atlas"
			local json = "spine/spine_target_effect/"..targetConfig.target_id..".json"
			spine = sp.SkeletonAnimation:create(json, atlas, targetConfig.skill_scale)
		end
		spine:setTimeScale(BattleUI.getAnimSpeed())
		print("4")
		spine:registerSpineEventHandler(function(event) 
			if event.type == "complete" and event.trackIndex == ANIM_TYPE.TARGET then
				spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
					spine:removeFromParent()
				end)))
			elseif event.type == "event" then
				print("dispatch target effect event: ", event.eventData.name, tostring(spine), self.isPet, self.index, self:getSkillConfig().id)
				local customEvent = cc.EventCustom:new("event_unit_act")
				customEvent._usedata = {name=event.eventData.name, unit=self}
				if event.eventData.name == "hit" then
					customEvent._usedata.targets = {target}
				end
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end)

		if not self.isPet then
			spine:setScaleX(-1)
		end
		self.effectIndex = self.effectIndex + 1 
		spine:setPosition(cc.p(target.layout:getPosition()))
		spine:setAnimation(ANIM_TYPE.TARGET, "part1", false)
		return spine
	end

	self.targetEffects = {}

	if not targets then
		if self:getSkillConfig().skill_type == 1 then
			targets = self.enemyTargets
		elseif self:getSkillConfig().id == 129 then
			local skillConfig = self:getSkillConfig()
			local extraEffectId = skillConfig.ext_effect_id
			local extConfig = ConfigManager.getSkillExtraEffectConfig(extraEffectId)
			pos = extConfig.special_param
			for i,v in ipairs(pos) do
				if v > 0 then
					local demonUnit = self:createAsDemon(v, i)
					local demonsPos = BattleUI:getPetPosition()
					local demonPos = demonsPos[(i + 2) % 6 + 1]
              		demonPos = cc.p(demonPos.x + 360, demonPos.y)
              		
					-- targets = target
					local spine = createEffect(demonUnit, i)
					spine:setPosition(demonPos)
					table.insert(self.targetEffects, spine)
				end
			end
			return self.targetEffects
		else
			targets = self.partnerTargets
		end
	end
	print("获得目标个数 ＝ "..#targets)
	for i,t in ipairs(targets) do
		local spine = createEffect(t, i)
		table.insert(self.targetEffects, spine)
	end
	print("target amount  = "..#self.targetEffects)
	return self.targetEffects
end

function PetUnit:getSuperSkillEffects() 
	function createEffect(target)
		-- print(targetConfig.target_id)
		local atlas = TextureManager.RES_PATH.SPINE_SUPER_EFFECT..".atlas"
		local json = TextureManager.RES_PATH.SPINE_SUPER_EFFECT..".json"
		local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		spine:setTimeScale(0.5*BattleUI.getAnimSpeed())
		print("5")
		spine:registerSpineEventHandler(function(event) 
			if event.type == "complete" and event.trackIndex == ANIM_TYPE.TARGET then
				spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
					spine:removeFromParent()
				end)))
			elseif event.type == "event" then
				local customEvent = cc.EventCustom:new("event_unit_act")
				customEvent._usedata = {name=event.eventData.name, unit=self}
				if event.eventData.name == "hit" then
					print("supter skill effect hit event", event.eventData.name, self:getSkillConfig().id)
					customEvent._usedata.targets = {target}
				end
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end)
		spine:setPosition(cc.p(self.layout:getPosition()))
		spine:setAnimation(ANIM_TYPE.TARGET, "part1", false)
		if not self.isPet then
			return
		else
			return spine
		end
	end

	self.superEffects = {}

	local targets
	if self:getSkillConfig().skill_type == 1 then
		targets = self.enemyTargets
	else
		targets = self.partnerTargets
	end
	for i,t in ipairs(targets) do
		local spine = createEffect(t)
		table.insert(self.superEffects, spine)
	end
	return self.superEffects
end

function PetUnit:runAttackedAnim()
	print(self.index, self.spine, self.release)
	self.spine:setAnimation(ANIM_TYPE.PET, "attacked", false)
	if self.actionStatus == ACTION_STATUS.ATTACK then
		self:moveBack()
	else
		self.spine:addAnimation(ANIM_TYPE.PET, "breath", true)
	end
end

function PetUnit:getActionEffects( )
	print("get action effect", self.index, self:getSkillConfig().id)
	local function createEffect()
		print("create action effect", self.model, self:getValidSkillIndex())
		local actionConfig = ConfigManager.getEffectConfig(self.model, self:getValidSkillIndex())
		print(actionConfig.action_id)
		local key = "spine/spine_action_effect/"..actionConfig.action_id
		local spine = SpineCache:getInstance():getSpine(key)
		if spine then
			spine:removeFromParent()
		else
			local atlas = "spine/spine_action_effect/"..actionConfig.action_id..".atlas"
			local json = "spine/spine_action_effect/"..actionConfig.action_id..".json"
			spine = sp.SkeletonAnimation:create(json, atlas, actionConfig.skill_scale)
		end
		spine:setTimeScale(BattleUI.getAnimSpeed())
		print("6")
		spine:registerSpineEventHandler(function(event)
			if event.type == "complete" and event.trackIndex == ANIM_TYPE.SKILL then
				if event.animation == self:getSkillAnimName("part1") then
					if not spine:setAnimation(ANIM_TYPE.SKILL, self:getSkillAnimName("part2"), false) then
						spine:removeFromParent()
					end
				end
			elseif event.type == "event" then
				print("dispatch action effect event: ", event.eventData.name, tostring(spine), self.isPet, self.index, self:getSkillConfig().id)
				local customEvent = cc.EventCustom:new("event_unit_act")
				customEvent._usedata = {name=event.eventData.name, unit=self}
				if event.eventData.name == "hit" then
					customEvent._usedata.targets = (self:getSkillConfig().skill_type == 1) and self.enemyTargets or self.partnerTargets
				end
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end)
		local pos = cc.p(self.layout:getPosition())
		local actionPos = actionConfig.action_pos
		if not self.isPet then
			spine:setScaleX(-1)
			spine:setPosition(cc.p(pos.x - actionPos[1], pos.y + actionPos[2]))
		else
			spine:setPosition(cc.p(pos.x + actionPos[1], pos.y + actionPos[2]))
		end
		
		spine:setAnimation(ANIM_TYPE.ACTION, "part1", false)
		return spine
	end

	self.actionEffects = {}

	local targets
	if self:getSkillConfig().skill_type == 1 then
		targets = self.enemyTargets
	else
		targets = self.partnerTargets
	end

	local spine = createEffect()
	table.insert(self.actionEffects, spine)
	
	return self.actionEffects
end

function PetUnit:attacked(damage)
	-- damage = 0

	if self.curHP <= 0 then
		return
	end

	self:runAttackedAnim()
	
	self.curHP = self.curHP - damage
	-- print("pet unit attacked, curHP: ", self.curHP)
	if self.curHP <= 0 and self.status ~= PET_UNIT_STATUS.DEAD then
		self:die()
	end

	self.lastAttackedDamage = damage
end

function PetUnit:die()
	self.status = PET_UNIT_STATUS.DEAD
	local spine = self.spine
	spine:setAnimation(ANIM_TYPE.PET, "die", false)
	spine:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
		spine:removeFromParent()
		spine:release()
	end)))
	if self.changeToBall then
		local parent = self.spine:getParent()
		local atlas = TextureManager.RES_PATH.SPINE_SPRITE_BALL .. ".atlas"
	    local json = TextureManager.RES_PATH.SPINE_SPRITE_BALL .. ".json"
		self.spine = sp.SkeletonAnimation:create(json, atlas, 1)
		self.spine:setTimeScale(BattleUI.getAnimSpeed())
		self.spine:retain()
		print("7")
		self:registerPetSpineEventHandler(self.spine)
		self.spine:setPosition(cc.p(50, 0))
		parent:addChild(self.spine)
		self.spine:setAnimation(1, "petback", false)
		self.spine:setAnimation(ANIM_TYPE.PET, "petback", false)
		self.spine:addAnimation(ANIM_TYPE.PET, "breath", true, 0.5)
		self.pwoer = 0
	else
		self.spine = nil
	end
	self.shadow:setVisible(false)

	self:removeAllBuffs()
	self:removeAllDebuffs()
	
	self:refreshBuffDebuffIcons()

	Utils.dispatchCustomEvent("event_unit_act", {unit=self, name="die"})

	PassiveSkillManager.removePassiveSkill(self)
end

-- 复活
-- hp: 复活后血量
-- effect: 复活时播放的特效
function PetUnit:relive(hpRate, effect)
	if effect then
		effect:retain()
	end
	self.status = PET_UNIT_STATUS.IDLE
	if self.spine then
		self.spine:removeFromParent()
		self.spine:release()
	end
	self:initSpine()
	self.spine:setOpacity(0)

	self.spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
		self.spine:setOpacity(255)
		self.spine:setAnimation(ANIM_TYPE.PET, "emerge", false)
		self.spine:addAnimation(ANIM_TYPE.PET, "breath", true, 0.5)
		self.actionStatus = ACTION_STATUS.BREATH

		if effect then
			local pos = cc.p(self.layout:getPosition())
			Utils.dispatchCustomEvent("event_battle_effect", {effect=effect, pos=pos, time=3.0})
			effect:release()
		end
	end)))

	self.curHP = self.maxHP * hpRate

	if self.hpProgress then
		self.hpProgress:setMaxValue(self.maxHP)
		self.hpProgress:setValue(self.curHP)
	end
end

function PetUnit:healed(amount)
	
	local tmpHP = self.curHP + amount
	self.curHP = tmpHP
	if self.curHP > self.maxHP then
		self.curHP = self.maxHP
	end
end

function PetUnit:initSpine()
	if not self.layout then
		local layout = CLayout:create()
		layout:retain()
		layout:setAnchorPoint(0.5, 0)
		layout:setContentSize(cc.size(100, 100))
		self.layout = layout
    end

    if not self.shadow then
		local shadow = TextureManager.createImg(TextureManager.RES_PATH.UNIT_SHADOW)
		if shadow then
			shadow:setPosition(cc.p(50, 0))
			self.layout:addChild(shadow)
			self.shadow = shadow
		end
	end

	local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, self.model) .. ".atlas"
	local json = string.format(TextureManager.RES_PATH.SPINE_PET, self.model) .. ".json"

	if self.isBoss then
		atlas = string.format(TextureManager.RES_PATH.SPINE_BOSS, self.model) .. ".atlas"
		json = string.format(TextureManager.RES_PATH.SPINE_BOSS, self.model) .. ".json"
	end

	local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	spine:setTimeScale(BattleUI.getAnimSpeed())
	spine:setAnimation(ANIM_TYPE.PET, "breath", true)
	spine:setMix("walk", "breath", 0.2)
	spine:setPosition(cc.p(50, 0))
	self.layout:addChild(spine)
	spine:retain()
	print("1")
	self:registerPetSpineEventHandler(spine)
	self.spine = spine
end

function PetUnit:registerPetSpineEventHandler(spine)
	print("8")
	spine:registerSpineEventHandler(function(event)
		if event.type == "complete" and event.trackIndex == ANIM_TYPE.PET and event.animation ~= "breath" then
			if string.sub(event.animation, -4) == "cast" then
				print("cast")
				self:finishCast()
			elseif string.sub(event.animation, -6) == "attack" then
				print("attack")
				self:moveBack()
			elseif event.animation == "die" then
				-- spine:removeFromParent()
				-- spine:release()
				-- spine = nil
			end
		elseif event.type == "event" then
			local customEvent = cc.EventCustom:new("event_unit_act")
			customEvent._usedata = {name=event.eventData.name, unit=self}
			print("self effect event", event.eventData.name, self:getSkillConfig().id, tostring(spine))
			if event.eventData.name == "hit" then
				customEvent._usedata.targets = (self:getSkillConfig().skill_type == 1) and self.enemyTargets or self.partnerTargets
			end
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		end
	end)
end

function PetUnit:init(pet, index)
	local formConfig = ConfigManager.getPetFormConfig(pet:get("mid"), pet:get("form"))
	self.model = formConfig.model
	self.pet = pet
	self.maxHP = self:getPetAttribute(Constants.PET_ATTRIBUTE.HP)
	self.curHP = pet:get("hp")
	self.curHP = (self.curHP > 0) and self.curHP or self.maxHP
	self.power = 0
	if index then
		self:initSpine()
		self.index = index
		self.status = PET_UNIT_STATUS.IDLE
		if self.shadow then
			self.shadow:setVisible(false)
		end
	
		self.changeToBall = true
	end
	PassiveSkillManager.addPassiveSkill(self)
end

function PetUnit:create(pet, index)
	local pu = PetUnit.new()
	pu:init(pet, index)
	return pu
end

function PetUnit:initAsDemon(monsterId, index, pet)
	self.isPet = false
	self.power = 0
	self.index = index
	self.status = PET_UNIT_STATUS.IDLE
	if pet then
		local formConfig = ConfigManager.getPetFormConfig(pet:get("mid"), pet:get("form"))
		self.pet = pet
		self.model = formConfig.model
		self.maxHP = self:getPetAttribute(Constants.PET_ATTRIBUTE.HP)
		self.curHP = pet:get("hp")
		self.curHP = (self.curHP > 0) and self.curHP or self.maxHP
		self:initSpine()
		self.spine:setScaleX(-1)
	else
		local monsterConfig = ConfigManager.getMonsterConfig(monsterId)
		Debug.simplePrintTable(monsterConfig)
		self.model = monsterConfig.model
		self.skillId = monsterConfig.skills[self.livedRound % (#monsterConfig.skills) + 1]
		self.monsterId = monsterId
		self.isBoss = (monsterConfig.isBoss == 1)
		self.maxHP = monsterConfig.attributes[Constants.PET_ATTRIBUTE.HP]
		self.curHP = self.maxHP

		-- 为了让宠物和怪物有统一的计算属性的方法给怪物增加一个虚拟的pet
		pet = Pet:create()
		pet:set("isDirty", false)
		pet:set("level", monsterConfig.level)
		pet:set("attributes", monsterConfig.attributes)
		self.pet = pet
		self:initSpine()
		-- 2000以上为贪财猫、宝箱等特殊怪物
		if (monsterId and (monsterId <= 2000 or monsterId >= 3000)) then
			self.spine:setScaleX(-1)
		end
	end
	PassiveSkillManager.addPassiveSkill(self)
end

function PetUnit:createAsDemon(monsterId, index, pet)
	local pu = PetUnit.new()
	pu:initAsDemon(monsterId, index, pet)
	return pu
end

function PetUnit:cleanup()
	print("clean up pet unit", self.isPet and "pet" or "demon", self.index)
	if self.layout and self.layout.release then
		self.layout:removeFromParent()
		self.layout:release()
		if self.ballSpine ~= nil then
			self.ballSpine:release()
		end
		if self.spine ~= nil then
			self.spine:release()
		end
	end
	if self.debuffs then
		for i,debuff in ipairs(self.debuffs) do
			debuff:cleanup()
		end
	end
	if self.buffs then
		for i,buff in ipairs(self.buffs) do
			buff:cleanup()
		end
	end

	PassiveSkillManager.removePassiveSkill(self)
	self:removeEventListeners()
end

function PetUnit:removeEventListeners()
	for i,v in ipairs(self.eventListeners) do
		cc.Director:getInstance():getEventDispatcher():removeEventListener(v)
	end
end

function PetUnit:isReady()
	local ready = (self.status == PET_UNIT_STATUS.IDLE) or (self.isPet and self.status ~= PET_UNIT_STATUS.ACTIVE)
	if not ready or self.spine == nil then
		return false
	end

	if self.debuffs then
		for i,debuff in ipairs(self.debuffs) do
			if debuff.type == 3 and debuff.rounds > 0 then
				return false
			end
		end
	end
	return true
end

function PetUnit:isDead()
	return self.status == PET_UNIT_STATUS.DEAD
end

function PetUnit:isAvailable()
	return self.status ~= PET_UNIT_STATUS.DEAD
end

function PetUnit:getSkillDuration()
	return 2.0
end

function PetUnit:win()
	if not self:isDead() then
		self.spine:setAnimation(ANIM_TYPE.PET, "win", true)
	end
end

function PetUnit:assemblePower(p)
	self.power = self.power + p
	if self.power > 100 then
		self.power = 100
	end
end

function PetUnit:getPetAttribute(attributeId)
	print("************************", "attribute:", self.isPet and "pet" or "demon", self.index, attributeId, "************************")
	local basicAttrib
	local attribBonus
	 
	 if self.monsterId then
	 	basicAttrib = self.pet:get("attributes")[attributeId] or 0
	 	attribBonus = 0
	 else
	 	basicAttrib = self.pet:getBasicAttribute(attributeId) or 0
	 	attribBonus = self.pet:getAttributeBonus(attributeId) or 0
	 end


	-- print("get pet attribute", self.isPet, attributeId, basicAttrib, attribBonus)

	-- 最终免伤比的计算方式和其他属性不同 damageReduce = (1 - r1) * (1 - r2)...
	local damageRate = 1.0

	local buffBonus = 0
	local buffBasic = 0
	if self.buffs then
		for i,bf in ipairs(self.buffs) do
			if (bf.type == BUFF_TYPES.ATTRIBUTE)
				 and (bf.attribId == attributeId)
				 and (bf.rounds > 0)  then
				buffBasic = buffBasic + bf.value + bf.value_growth * bf.skill_level
				buffBonus = buffBonus + bf.percent + bf.percent_growth * bf.skill_level

				if attributeId == Constants.PET_ATTRIBUTE.DAMAGE_REDUCE then
					damageRate = damageRate * (1 - (bf.percent + bf.percent_growth * bf.skill_level))
				end
				-- print("*** reduce by buff", damageRate)
			end
		end
	end
	
	local debuffBonus = 0
	local debuffBasic = 0
	if self.debuffs then
		for i,dbf in ipairs(self.debuffs) do
			if (dbf.type == DEBUFF_TYPES.ATTRIBUTE)
				 and (dbf.attribId == attributeId)
				 and (dbf.rounds > 0) then
				debuffBasic = debuffBasic + dbf.value + dbf.value_growth * dbf.skill_level
				debuffBonus = debuffBonus + dbf.percent + dbf.percent_growth * dbf.skill_level
				
				if attributeId == Constants.PET_ATTRIBUTE.DAMAGE_REDUCE then
					damageRate = damageRate * (1 - (bf.percent + bf.percent_growth * bf.skill_level))
				end
				-- print("*** reduce by debuff", damageRate)
			end
		end
	end

	local passiveBonus = 0
	local passiveBasic = 0
	local passiveSkills = self.index and PassiveSkillManager.getPassiveSkills(self) or {}
	if passiveSkills then
		for i,psa in ipairs(passiveSkills) do
			if self.index > 0 then
				passiveBasic = passiveBasic + psa:getAttr(self, attributeId)
				passiveBonus = passiveBonus + psa:getAttrBonus(self, attributeId)
			else
				passiveBasic = passiveBasic + psa:getPermanentAttr(self, attributeId)
				passiveBonus = passiveBonus + psa:getPermanentAttrBonus(self, attributeId)
			end
			
			if attributeId == Constants.PET_ATTRIBUTE.DAMAGE_REDUCE then
				damageRate = damageRate * (1 - psa:getAttrBonus(self, attributeId))
			end
			-- print("*** reduce by pasive skill", damageRate)
		end
	end

	if attributeId == Constants.PET_ATTRIBUTE.DAMAGE_REDUCE then
		-- print("***", 1 - damageRate)
		return 1 - damageRate
	end

	print("basicAttrib:"..basicAttrib, "buffBasic:"..buffBasic, "debuffBasic:"..debuffBasic, "passiveBasic:"..passiveBasic, "attribBonus:"..attribBonus, "buffBonus:"..buffBonus, "debuffBonus:"..debuffBonus, "passiveBonus:"..passiveBonus)
	print(print("attribute:",(basicAttrib + buffBasic - debuffBasic + passiveBasic) * (1 + attribBonus/100.0 + buffBonus/100.0 - debuffBonus/100.0 + passiveBonus/100.0)))
	return (basicAttrib + buffBasic - debuffBasic + passiveBasic) * (1 + attribBonus/100.0 + buffBonus/100.0 - debuffBonus/100.0 + passiveBonus/100.0)
end

function PetUnit:isActive()
	return self.status == PET_UNIT_STATUS.ACTIVE and self.spine ~= nil
end

function PetUnit:disactivate()
	if self:isActive() then
		self.status = (self.curHP > 0) and PET_UNIT_STATUS.IDLE or PET_UNIT_STATUS.DEAD
	end
	self.livedRound = self.livedRound + 1;
	print(" disactivate ")
	if self.SuperDreamSpine ==1 and self.livedRound == 3 then
		self.SuperDreamSpine  = self.SuperDreamSpine + 1
		local customEvent = cc.EventCustom:new("remove_superdream_spine")
   		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	end

end

-- unitA为进攻方，unitB为防御方
-- 防御方等级-攻击方等级   绝对值大于2时有效，否则为0
local function getLevelDiff(unitA, unitB)
	local levelDiff = unitB.pet:get("level") - unitA.pet:get("level")
	if math.abs(levelDiff) <= 2 then
		levelDiff = 0
	end
	return levelDiff
end

-- 暴击率 ＝ A的总暴击－双方等级差／等级压制系数
function PetUnit:getFinalCritRate(unitB)
	-- 总暴击率
	local critRate
	local levelDiff
	local levelSuppression

	-- 总暴击固定值/暴闪系数+总附加暴击率+基础暴击率
	local crit = self:getPetAttribute(Constants.PET_ATTRIBUTE.CRIT)
	local extraCritRate = self:getPetAttribute(Constants.PET_ATTRIBUTE.CRIT_RATE) * 0.01
	local critDodgeCoefficient = ConfigManager.getPetCommonConfig("crit_dodge_coefficient")
	local basicCrit = ConfigManager.getPetCommonConfig("basic_crit")/100.0
	critRate = crit/critDodgeCoefficient + extraCritRate + basicCrit

	levelDiff = unitB and getLevelDiff(self, unitB) or 0
	levelSuppression = ConfigManager.getPetCommonConfig("level_suppression")

	return critRate - levelDiff/levelSuppression
end

-- 命中率 ＝ 1-B的总闪避率－双方等级差／等级压制系数
function PetUnit:getHitRate(unitA)
	local dodgeRate
	local levelDiff
	local levelSuppression

	-- 总闪避固定值/暴闪系数+总附加闪避率
	local dodge = self:getPetAttribute(Constants.PET_ATTRIBUTE.DODGE)
	local extraDodgeRate = self:getPetAttribute(Constants.PET_ATTRIBUTE.DODGE_RATE) * 0.01
	local critDodgeCoefficient = ConfigManager.getPetCommonConfig("crit_dodge_coefficient")
	dodgeRate = dodge/critDodgeCoefficient + extraDodgeRate
	-- print("calculate dodge", dodge, dodgeBonus, critDodgeCoefficient)
	-- print("dodgeRate", dodgeRate)

	levelDiff = unitA and getLevelDiff(unitA, self) or 0
	-- print("levelDiff", levelDiff)

	levelSuppression = ConfigManager.getPetCommonConfig("level_suppression")
	-- print("levelSuppression", levelSuppression)
	-- print("final", 1 - dodgeRate - levelDiff/levelSuppression)

	-- return 1 - dodgeRate * (1 + levelDiff/levelSuppression)
	return 1 - dodgeRate - levelDiff/levelSuppression
end

-- B的最终受伤值 = B的受伤值 *（1+消除能量值/能量系数）
-- skillConfig可能为A的技能
function PetUnit:getFinalCommonDamage(unitA, isCrit)
	local unitB = self

	-- 闪避
	if unitB:getHitRate(unitA) * 100 < math.random(100) then
		return 0.01
	end

	local damage
	local powerCoefficient = ConfigManager.getPetCommonConfig("crit_dodge_coefficient")

	--A的总攻击 ＝ 总攻击固定值＊（1+总攻击百分比）
	-- （A的总普通攻击*A的技能百分比+A的技能附加值）*（1+A的总暴击系数）*B的普通受伤比+A的总穿透伤害
	local attack = unitA:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
	
	local skillConfig = unitA:getSkillConfig()
	local critCoefficient = 0
	local targetDamageRate = 1.0
	-- local penetrateDamage = unitA:getPetAttribute(Constants.PET_ATTRIBUTE.PENETRATE_DAMAGE)

	-- （总附加暴击伤害+基础暴击伤害）/100
	if isCrit then
		local critDamage = unitA.pet:getBasicAttribute(Constants.PET_ATTRIBUTE.CRIT_DAMAGE)
		local basicCritDamage = ConfigManager.getPetCommonConfig("basic_crit_damage")
		critCoefficient = (critDamage + basicCritDamage)/100.0
	end
	local targetDamageRate = 1 - unitB:getPetAttribute(Constants.PET_ATTRIBUTE.DAMAGE_REDUCE)/100.0

	local skillLevel = unitA.pet:get("skillLevels")[self:getSkillConfig().index] --- 1
	if skillLevel == nil then
		skillLevel = 1
	end
	-- skillLevel = skillLevel - 1
	print(" ----------------------------------------  ")
	print("    *******    "..unitB:getPetAttribute(Constants.PET_ATTRIBUTE.DAMAGE_REDUCE))
	print("                          attack  = "..attack)
	print("      skillConfig.effect_percent  = "..skillConfig.effect_percent )
	print("skillConfig.effect_percent_growth = "..skillConfig.effect_percent_growth)
	print("                       skillLevel = "..skillLevel)
	print("         skillConfig.effect_value = "..skillConfig.effect_value)
	print("  skillConfig.effect_value_growth = "..skillConfig.effect_value_growth )
	print("                 critCoefficient  = "..critCoefficient)
	print("                targetDamageRate  = "..targetDamageRate)
	damage = (attack * (skillConfig.effect_percent + skillConfig.effect_percent_growth * skillLevel)/100.0 + (skillConfig.effect_value + skillConfig.effect_value_growth * skillLevel)) * (1 + critCoefficient) * targetDamageRate
	print("                          damage  = "..damage)
	print(" -----------------------------------------  ")
	-- buff吸收
	local buffAbsorb = 0

	if self.buffs then
		for i,buff in ipairs(self.buffs) do
			if buff.type == 1 then
				local abd = buff:getAbsorb(unitB)
				print("buff ".. buff.id .. " absorb " .. abd)
				buffAbsorb = buffAbsorb + abd
			elseif buff.type == 4 then
				Utils.dispatchCustomEvent("event_attack_all", {targets={unitA}, damage=buff:getReflection(unitB)})
			end
		end
	end
	damage = damage - buffAbsorb 
	if damage < 0 then
		damage = 0
	end

	print("************************", unitA.index.." > "..unitB.index, "************************")
	print("skillId:"..skillConfig.id, "attack:"..attack, "skill_effect_percent:"..skillConfig.effect_percent, "skillLevel:"..skillLevel, "skillConfig.effect_value:"..skillConfig.effect_value, "skillConfig.effect_value_growth:"..skillConfig.effect_value_growth, "critCoefficient:"..critCoefficient, "targetDamageRate:"..targetDamageRate)
	print("damage ="..damage)
	-- 计算被动技能对最终结算的影响
	-- local r = 0
	-- local passiveSkills = PassiveSkillManager.getPassiveSkills(unitB)
	-- if passiveSkills then
	-- 	for i=1,#passiveSkills do
	-- 		r = r + passiveSkills[i]:getFinalReduceValue(unitA, unitB, damage)
	-- 	end
	-- end
	-- damage = damage - r
	print("     unitA.power  = "..unitA.power)
	print("power_coefficient = "..ConfigManager.getPetCommonConfig("power_coefficient"))
	damage = math.ceil(damage * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient")) / skillConfig.hits)
	-- print(""..damage * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient")) / skillConfig.hits)
	print("get damage", tostring(self), self.index, self.isPet, self.damage)

	print("*****************宠物伤害值*******************".. damage)
	if unitA.damage == nil then
		return damage
	else
		unitA.damage = unitA.damage + damage
		return damage
	end
end

-- A的最终治疗值 = A的治疗值 *（1+消除能量值/能量系数）
function PetUnit:getFinalCommonHeal(unitA, isCrit)
	local unitB = self
	--（A的总普通攻击*A的技能百分比+A的技能附加值）*（1+A的总暴击系数）
	local skillConfig = unitA:getSkillConfig()
	local attack = unitA:getPetAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
	local skillConfig = unitA:getSkillConfig()
	local critCoefficient = 0
	if isCrit then
		local critDamage = unitA.pet:getBasicAttribute(Constants.PET_ATTRIBUTE.CRIT_DAMAGE)
		local basicCritDamage = ConfigManager.getPetCommonConfig("basic_crit_damage")
		critCoefficient = (critDamage + basicCritDamage)/100.0
	end
	local skillLevel = self.pet:get("skillLevels")[self:getSkillConfig().index] -- 1
	if skillLevel == nil then
		skillLevel = 1
	end
	
	-- skillLevel = skillLevel - 1
	local heal = (attack * (skillConfig.effect_percent + skillConfig.effect_percent_growth * skillLevel)/100.0 + (skillConfig.effect_value + skillConfig.effect_value_growth * skillLevel)) * (1 + critCoefficient)

	print("heal: ")
	print("attack", attack)
	print("skillLevel", skillLevel)
	print("skillConfig.effect_percent", skillConfig.effect_percent)
	print("skillConfig.effect_percent_growth", skillConfig.effect_percent_growth)
	print("skillConfig.effect_value", skillConfig.effect_value)
	print("skillConfig.effect_value_growth", skillConfig.effect_value_growth)
	print("critCoefficient", critCoefficient)
	print("unitA.power", unitA.power)
	print("power_coefficient", ConfigManager.getPetCommonConfig("power_coefficient"))
	print("final", math.ceil(heal * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient"))))

	return math.ceil(heal * (1 + unitA.power/ConfigManager.getPetCommonConfig("power_coefficient")))
end

function PetUnit:handleBuffDebuff()
	local skillLevel = self.pet:get("skillLevels")[self:getSkillConfig().index]
	local skillConfig = self:getSkillConfig()
	print("buff debuff 处理时间到")
	print("buff debuff "..skillConfig.debuff_id ,skillConfig.buff_id)
    -- 产生debuff
    if skillConfig.debuff_id > 0 then
    	for i,target in ipairs(self.enemyTargets) do
    		if not target:isDead() then
    			target:addDebuff(skillConfig.debuff_id, self, skillLevel, true)
    		end
    	end
    end

    -- 产生buff
    if skillConfig.buff_id > 0 then
    	if #self.partnerTargets == 0 then
    		if not self:isDead() then
	    		self:addBuff(skillConfig.buff_id, self, skillLevel, true)
	    		return
	    	end
    	end
    	for i,target in ipairs(self.partnerTargets) do
    		if not target:isDead() then
    			print(" 增加buff，增加后触发 ")
    			target:addBuff(skillConfig.buff_id, self, skillLevel, true)
    		end
    	end
    end
end
-- 增加buff，增加后触发
function PetUnit:addBuff(id, caster, skill_level, triggerImmediately)
	print("------------------------------------------------------")
	print(" add buff", id, skill_level, caster.isPet, caster.index)
	print("------------------------------------------------------")
	if self:isDead() then
		return
	end

	self.buffs = self.buffs or {}

	for i,bf in ipairs(self.buffs) do
		if bf.id == id then
			bf:layerUp()
			if triggerImmediately then
				self:triggerBuff(bf, true)
			end
			return
		end
	end
	-- print("buff id = "..id ..",  skill_level = "..skill_level)
	local buff = Buff:create(id, caster, skill_level)
	if skill_level == nil then
		skill_level = 1
	end
	table.insert(self.buffs, skill_level, buff)

	if triggerImmediately then
		self:triggerBuff(buff, true)
	end

	self:refreshBuffDebuffIcons()
end

-- 增加debuff，增加后出发
function PetUnit:addDebuff(id, caster, skill_level, triggerImmediately)
	print("add debuff", id, skill_level, caster and caster.isPet, caster and caster.index, skill_level, triggerImmediately)
	if self:isDead() then
		return
	end

	self.debuffs = self.debuffs or {}
	for i,dbf in ipairs(self.debuffs) do
		if dbf.id == id then
			dbf:layerUp()
			if triggerImmediately then
				self:triggerDebuff(dbf, true)
			end
			return
		end
	end

	local debuff = Debuff:create(id, caster, skill_level)
	table.insert(self.debuffs, debuff)

	if triggerImmediately then
		self:triggerDebuff(debuff, true)
	end

	self:refreshBuffDebuffIcons()
end

-- 触发debuff
-- forceShowEffect 是否强制播放特效，掉血类buff触发即播放特效，无视该参数，其它类buff仅添加时播放特效，在addBuff方法中调用时通过该参数播放特效
-- return 是否需要播放特效
function PetUnit:triggerBuff(buff, forceShowEffect)
	if buff.rounds <= 0 then
		return false
	end

	local ret = false
	
	-- 类型（1:恢复，2:影响属性，3: 吸收伤害，4:反射伤害）
	if buff.type == 1 or forceShowEffect then
		local customEvent = cc.EventCustom:new("event_trigger_buff_debuff")
		customEvent._usedata = {}
		customEvent._usedata.target = self
		customEvent._usedata.damage = -buff:getHeal() * buff.layers
		customEvent._usedata.effect = buff:getEffect()
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		ret = true
	elseif buff.type == 4 then
		
		ret = false
	end

	return ret
end

-- 触发debuff
-- forceShowEffect 是否强制播放特效，掉血类debuff触发即播放特效，无视该参数，控制类和属性类debuff仅添加时播放特效，在addDebuff方法中调用时通过该参数播放特效
-- return 是否需要播放特效
function PetUnit:triggerDebuff(debuff, forceShowEffect)
	if debuff.rounds <= 0   then
		return false
	end

	local ret = false
	
	-- 类型(1: 掉血，2:影响属性，3:控制)
	if debuff.type == 1 or forceShowEffect then
		local customEvent = cc.EventCustom:new("event_trigger_buff_debuff")
		customEvent._usedata = {}
		customEvent._usedata.target = self
		customEvent._usedata.damage = (debuff.type == 1) and (debuff:getDamage(self) * debuff.layers) or 0
		customEvent._usedata.effect = debuff:getEffect()

		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		ret = true
	end

	return ret
end

function PetUnit:prepareToFight() 
	self:triggerBuffDebuff()
end

function PetUnit:triggerBuffDebuff()
	if self:isDead() then
		return false
	end
	
	local ret = false
	if self.debuffs then
		-- 首先移除剩余回合数为0的debuff，本回合出发后剩余回合数为0的debuff将在下一回合开始时被移除
		for i,debuff in ipairs(self.debuffs) do
			ret = self:triggerDebuff(debuff) or ret
		end
	end

	if self.buffs then
		for i,buff in ipairs(self.buffs) do
			ret = self:triggerBuff(buff) or ret
		end
	end

	return ret
end

-- buff/debuff回合数减一并移除已经结束的buff／debuff
function PetUnit:clearBuffDebuff()
	if self.debuffs then
		
		-- 首先移除剩余回合数为0的debuff，本回合出发后剩余回合数为0的debuff将在下一回合开始时被移除
		local tmp = {}
		for i,debuff in ipairs(self.debuffs) do
			debuff.rounds = debuff.rounds - 1
			print("debuff的回合数 ", debuff.id, debuff.rounds)
			if debuff.rounds > 0 then
				table.insert(tmp, debuff)
			else
				debuff:cleanup()
				-- debuff = nil
				-- local customEvent = cc.EventCustom:new("event_remove_buff_debuff")
				-- customEvent._usedata = {}
				-- customEvent._usedata.target = self
				-- -- customEvent._usedata.damage = (debuff.type == 1) and (debuff:getDamage(self) * debuff.layers) or 0
				-- customEvent._usedata.effect = debuff:getEffect()
				-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end
		self.debuffs = tmp
	end

	if self.buffs then
		local tmp = {}
		for i,buff in ipairs(self.buffs) do
			buff.rounds = buff.rounds - 1
			print("buff的回合数 ", buff.id, buff.rounds)
			if buff.rounds > 0 then
				table.insert(tmp, buff)
			else
				buff:cleanup()
				-- local customEvent = cc.EventCustom:new("event_remove_buff_debuff")
				-- customEvent._usedata = {}
				-- customEvent._usedata.target = self
				-- customEvent._usedata.effect = buff:getEffect()
				-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end
		self.buffs = tmp
	end

	self:refreshBuffDebuffIcons()
end

function PetUnit:removeAllBuffDebuff()
	self:removeAllBuffs()
	self:removeAllDebuffs()
end

-- 移除所有buff
function PetUnit:removeAllBuffs()
	if self.buffs then
		local tmp = {}
		for i,buff in ipairs(self.buffs) do
			buff:cleanup()
			-- local customEvent = cc.EventCustom:new("event_remove_buff_debuff")
			-- customEvent._usedata = {}
			-- customEvent._usedata.target = self
			-- customEvent._usedata.effect = buff:getEffect()
			-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		end
		self.buffs = nil
	end
	self:refreshBuffDebuffIcons()
end

-- 移除所有debuff
function PetUnit:removeAllDebuffs()
	if self.debuffs then
		-- 首先移除剩余回合数为0的debuff，本回合出发后剩余回合数为0的debuff将在下一回合开始时被移除
		local tmp = {}
		for i,debuff in ipairs(self.debuffs) do
			debuff:cleanup()
			-- local customEvent = cc.EventCustom:new("event_remove_buff_debuff")
			-- customEvent._usedata = {}
			-- customEvent._usedata.target = self
			-- -- customEvent._usedata.damage = (debuff.type == 1) and (debuff:getDamage(self) * debuff.layers) or 0
			-- customEvent._usedata.effect = debuff:getEffect()
			-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		end
		self.debuffs = nil
	end
	self:refreshBuffDebuffIcons()
end

-- 施放技能附加效果
function PetUnit:handleSkillExtraEffect(petUnits, demonUnits)
	print("handle skill extra effect", self:getSkillConfig().id)

	local skillLevel = self.pet:get("skillLevels")[self:getSkillConfig().index]

	local function getExtTargets(extType, method, num)
		print("getExtTargets target method = "..method)
		if method == 1 then
			if extType == 1 then
				return self.partnerTargets
			elseif extType == 2 then
				return self.enemyTargets
			end
		elseif method == 2 then
			return {self}
		elseif method == 3 then
			local targets = {}
			if (extType == 1 and self.isPet) or (extType == 2 and not self.isPet) then
				targets = petUnits
			else
				targets = demonUnits
			end

			return Utils.randomElemsFromTable(targets, 6, num)
		end
	end

	local skillConfig = self:getSkillConfig()
	local extraEffectId = skillConfig.ext_effect_id

	print("@extraEffectId = "..extraEffectId)

	if extraEffectId == 0 then
		return
	end
	
	local extConfig = ConfigManager.getSkillExtraEffectConfig(extraEffectId)
	local probability = extConfig.probability

	print(extConfig.type.."@"..extConfig.target_method.."@"..extConfig.target_num, probability)

	-- 1: buff, 2: debuff, 3: 技能
	if extConfig.type == 1 then
		-- 特殊处理寄生种子的回血buff，每个目标叠加一层
		if extConfig.id == 1 then
			local targets = self.enemyTargets
			for i,target in ipairs(targets) do
				self:addBuff(extConfig.effect_id, self, skillLevel, true)
			end
		elseif probability >= math.random(100) then
			local targets = getExtTargets(extConfig.type, extConfig.target_method, extConfig.target_num)
			for i,target in ipairs(targets) do
				r = math.random(100)
				if target and not target:isDead() and probability >= r then
					target:addBuff(extConfig.effect_id, self, skillLevel, true)
				end
			end
		end
	elseif extConfig.type == 2 then
		local targets = getExtTargets(extConfig.type, extConfig.target_method, extConfig.target_num)
		print(extConfig.type.."@"..extConfig.target_method.."@"..extConfig.target_num, #targets)
		if targets then
			for i,target in ipairs(targets) do
				r = math.random(100)
				if target and not target:isDead() and probability >= r then
					target:addDebuff(extConfig.effect_id, self, skillLevel, true)
				end
			end
		end
	elseif extConfig.type == 4 then
		Utils.dispatchCustomEvent("event_block_unit", {block_type=extConfig.effect_id})
	elseif extConfig.type == 5 then  -- 按百分比回血
		if self.damage == 0 then
			return
		end
		local buff = Buff:create(3, self, 1)
		local customEvent = cc.EventCustom:new("event_trigger_buff_debuff")
		customEvent._usedata = {}
		customEvent._usedata.target = self
		customEvent._usedata.damage = math.ceil(-self.damage * extConfig.special_param/100.0)
		customEvent._usedata.effect = buff:getEffect()
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	elseif extConfig.type == 6 then  -- 召唤
		Utils.dispatchCustomEvent("event_summon_pets", {for_pet=false, positions=extConfig.special_param})
	elseif extConfig.type == 7 then  -- 驱散
		for i,pu in ipairs(self.partnerTargets) do
			if pu ~= nil then
				pu:removeAllDebuffs()
			end
		end
	end
end

function PetUnit:refreshBuffDebuffIcons()
	local idx = 0
	local xpos = 75
	local ypos = 10
	local xpos_offset = 25
	local ypos_offset = 28

	if self.layout:getChildByTag(BUFF_DEBUFF_LAYOUT_TAG) then
		self.layout:removeChildByTag(BUFF_DEBUFF_LAYOUT_TAG)
	end

	local bdlayout = CLayout:create()
	bdlayout:setAnchorPoint(cc.p(0, 0))
	bdlayout:setPosition(cc.p(xpos, ypos))
	bdlayout:setTag(BUFF_DEBUFF_LAYOUT_TAG)
	self.layout:addChild(bdlayout)
	print(self.layout:getChildByTag(BUFF_DEBUFF_LAYOUT_TAG))

	if self.debuffs then
		for i,debuff in ipairs(self.debuffs) do
			if debuff.attribId ~= 0 then
				local signImg = TextureManager.createImg(TextureManager.RES_PATH.IMG_DECREASE_ICON)
				local attrImg = TextureManager.createImg(TextureManager.RES_PATH.IMG_ATTRIB_ICON, debuff.attribId)
				signImg:setPosition(cc.p(xpos_offset, ypos_offset * idx))
				attrImg:setPosition(cc.p(0, ypos_offset * idx))
				bdlayout:addChild(signImg)
				bdlayout:addChild(attrImg)
				idx = idx + 1
			end
		end
	end

	if self.buffs then
		for i,buff in ipairs(self.buffs) do
			if buff.attribId ~= 0 then
				local signImg = TextureManager.createImg(TextureManager.RES_PATH.IMG_INCREASE_ICON)
				local attrImg = TextureManager.createImg(TextureManager.RES_PATH.IMG_ATTRIB_ICON, buff.attribId)
				signImg:setPosition(cc.p(xpos_offset, ypos_offset * idx))
				attrImg:setPosition(cc.p(0, ypos_offset * idx))
				bdlayout:addChild(signImg)
				bdlayout:addChild(attrImg)
				idx = idx + 1
			end
		end
	end
end

function PetUnit:getResources()
	local res = {}

	if self.model > 2000 and self.model < 3000 then
		return res
	end
	
	for i = 1, 3 do
		-- local skillConfig = ConfigManager.getSkillConfig(skillId)
		local skillEffectConfig = ConfigManager.getEffectConfig(self.model, i)
		if skillEffectConfig then
			if tostring(skillEffectConfig.skill_id) ~= "0" then
				local sp = "spine/spine_skill_effect/"..skillEffectConfig.skill_id
				table.insert(res, {key=sp, spine=sp})
			end
			if tostring(skillEffectConfig.action_id) ~= "0" then
				local sp = "spine/spine_action_effect/"..skillEffectConfig.action_id
				table.insert(res, {key=sp, spine=sp})
			end
			if tostring(skillEffectConfig.target_id) ~= "0" then
				local sp = "spine/spine_target_effect/"..skillEffectConfig.target_id
				table.insert(res, {key=sp, spine=sp})
			end
		end
	end

	return res
end
