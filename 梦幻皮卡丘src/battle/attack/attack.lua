require "battle/unit/demon"

local ATTACK_STATE = {
	INITED = 1,
	MOVING = 2,
	HITTING = 3,
	FINISHED = 4
}

local POSITION_FIX = cc.p(40, 0)

--[[	
		return Model:create("Attack", {
			-- 攻击类型 0: 近战, 1: 远程, 2: 穿刺, 3: 持续攻击（龙卷风）(注：如果攻击类型为3，则debuff_interval为攻击间隔，debuff_duration为攻击持续时间)
			atk_type = 0,
			-- 攻击来源 0: 自身，1: 屏幕外召唤（天降火球），2: 目标（龙卷风，地刺等）
			atk_origin = 0
			-- 攻击力 宠物本身的攻击力 + 5消加成 + bonus攻击加成	
			power = 0,
			-- 直接伤害与攻击力的比值
			damage_factor = 1000,
			-- 攻击次数（宠物单词施法打中目标的次数）
			hits = 0,
			-- 攻击范围 0: 单体, 1: 目标及所在列，2: 目标及所在行, 3: 目标及左右, 4: 目标及四周，5: 目标及前后左右，6: 目标及其它随机n个（相当于随机n+1个目标）
			range = 0,
			-- 选取攻击目标的方式 0: 随机, 1:所在列第一个 2: 所在列最后一个 3: 所在列随机
			aim_type = 0,
			-- buff 0: 无, 1: 回血, 2: 增加攻击, 3: 增加防御
			buff = 0,
			-- buff作用间隔(单位s)
			buff_interval = 1.0,
			-- buff持续时间(单位s)
			buff_duration = 3.0,
			-- buff效果与攻击力的比值
			buff_factor,
			-- debuff 0: 无, 1: 持续掉血, 2: 降低防御， 3: 降低攻击， 4: 眩晕, 5: 冰冻，
			debuff = 0,
			-- debuff作用间隔
			debuff_interval = 0,
			-- debuff持续时间
			debuff_duration = 0,
			-- debuff效果与攻击力的比值
			debuff_factor = 0,
			-- 特殊效果，如击飞等 0: 无
			special_effect = 0,	
			state = ATTACK_STATE.INITED,
		})
--]]

Attack = class("Attack", function()
	return Model:create("Attack", {
			atk_type = 0,
			atk_origin = 0,
			power = 0,
			damage_factor = 1000,
			hits = 0,
			range = 0,
			aim_type = 0,
			buff = 0,
			buff_interval = 0,
			buff_duration = 0,
			buff_factor = 0,
			debuff = 0,
			defuff_interval = 0,
			debuff_duration = 0,
			debuff_factor = 0,
			special_effect = 0,
			state = 0
		})
end)

Attack.pet_unit = nil
Attack.startPos = nil
Attack.spine = nil
Attack.availTargets = nil
Attack.target = nil
Attack.targetPos = nil
Attack.sprite = nil

function Attack:create(pet_unit, num, bonus)
	--todo: get attack config
	local pos = pet_unit.pos
	local atk = Attack:new()
	atk.pet_unit = pet_unit

	if pet_unit.mid == 1 then
		atk:set("atk_type", 0)
		atk:set("atk_origin", 0)
		atk:set("atk_power", 500)
		atk:set("damage_factor", 1000)
		atk:set("hits", 1)
		atk:set("range", 0)
		atk:set("aim_type", 1)
	elseif pet_unit.mid == 4 then
		atk:set("atk_type", 0)
		atk:set("atk_origin", 0)
		atk:set("atk_power", 500)
		atk:set("damage_factor", 1000)
		atk:set("hits", 1)
		atk:set("range", 0)
		atk:set("aim_type", 1)
	elseif pet_unit.mid == 7 then
		atk:set("atk_type", 2)
		atk:set("atk_origin", 0)
		atk:set("atk_power", 500)
		atk:set("damage_factor", 1000)
		atk:set("hits", 1)
		atk:set("range", 0)
		atk:set("aim_type", 0)
	elseif pet_unit.mid == 16 then
		atk:set("atk_type", 3)
		atk:set("atk_origin", 2)
		atk:set("atk_power", 500)
		atk:set("damage_factor", 0)
		atk:set("hits", 1)
		atk:set("range", 0)
		atk:set("aim_type", 0)
		atk:set("debuff_interval", 1.0)
		atk:set("debuff_duration", 3.0)
		atk:set("debuff_factor", 333)
	end

	-- 根据atk_type生成骨骼动画
	if atk:get("atk_type") == 0 then
		local atlas = string.format(TextureManager.RES_PATH.SPINE_PET_ATLAS, pet_unit.mid)
		local json = string.format(TextureManager.RES_PATH.SPINE_PET_JSON, pet_unit.mid)
    	local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    	spine:setAnimation(0, "walk", true)
		atk.spine = spine
	else
		local atlas = string.format(TextureManager.RES_PATH.SPINE_ATTACK_ATLAS, pet_unit.mid)
		local json = string.format(TextureManager.RES_PATH.SPINE_ATTACK_JSON, pet_unit.mid)
    	local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    	spine:setAnimation(0, "part1", true)
		atk.spine = spine
	end

	-- 根据atk_origin计算动画起始位置
	local origin = atk:get("atk_origin")
	if origin == 0 then
		atk.startPos = cc.pAdd(cc.pAdd(pos, Constants.MATRIX_POS), POSITION_FIX)
	elseif origin == 1 then
		local winSize = cc.Director:getInstance():getWinSize()
		-- atk:startPos = cc.p(winSize.width - 60, winSize.height + 60)
	end


	local sprite = CLayout:create()
	sprite:setAnchorPoint(cc.p(0, 0))
	sprite:addChild(atk.spine)
	atk.sprite = sprite

	atk:set("state", ATTACK_STATE.INITED)
	return atk
end

function Attack:findTarget(availTargets)
	self.target = nil
	if availTargets == nil then
		return
	end

	if self:get("aim_type") == 0 then
		local idx = self.pet_unit.index
		local col = idx % Constants.MATRIX_COL
		for i,demon in ipairs(availTargets) do
			local demonIdx = demon.index
			local demonCol = demonIdx % Constants.ENEMY_COL
			if demonCol == col then
				self.target = demon
				self.targetPos = cc.pAdd(cc.pAdd(cc.p(demon:getPosition()), Constants.ENEMY_POS), POSITION_FIX)
				return
			end
		end
	elseif self:get("aim_type") == 1 then
		self.target = availTargets[math.random(#availTargets)]
		self.targetPos = cc.pAdd(cc.pAdd(cc.p(self.target:getPosition()), Constants.ENEMY_POS), POSITION_FIX)
	end
end

function Attack:finishHit()
	if self.target and self.target.isAlive and self.target:isAlive() then
		self.target:hit(self:get("power"))
	end
	self:set("state", ATTACK_STATE.FINISHED)
end

local function hitCallFunc(sender, atk)
	local target = atk.target
	local spine = atk.spine
	print(spine)
	print(spine.setAnimation)
	local ret = 0
	if atk:get("atk_type") == 0 then
		ret = spine:setAnimation(0, "attack", false);
	elseif atk:get("atk_type") == 1 then
		ret = spine:setAnimation(0, "part2", false)
	end
	if (ret == 0) then
		atk:finishHit()
	else
		spine:registerSpineEventHandler(function(event)
			if event.type == 'complete' then
				if event.animation == "attack" or event.animation == "part2" then
					atk:finishHit()
				end
			end
		end)
	end
end

function Attack:getSprite()
	return self.sprite
end

function Attack:playMoveEffect()
	local startPos = cc.p(self.sprite:getPosition())
	if not self.targetPos then
		self.targetPos = cc.p(startPos.x, startPos.y + 1000)
	end
	if self:get("atk_type") == 0 then
		self.targetPos.y = self.targetPos.y - 60
	end
	local travelTime = cc.pGetDistance(startPos, self.targetPos)/Constants.PET_SPEED
	self.sprite:runAction(cc.Sequence:create(cc.MoveTo:create(travelTime, self.targetPos), cc.CallFunc:create(hitCallFunc, self)))

	self:set("state", ATTACK_STATE.MOVING)
end

function Attack:updateAttack(availTargets)
	self.availTargets = availTargets
	local state = self:get("state")
	if state == ATTACK_STATE.INITED then
		self:findTarget(availTargets)
		self.sprite:setPosition(self.startPos)
		self:playMoveEffect()
	end
end

function Attack:isFinished()
	return self:get("state") == ATTACK_STATE.FINISHED
end