SpecialDemon = class("SpecialDemon", function()
	return PetUnit.new()
end)

local ANIM_TYPE = {
	PET = 1,
	BALL = 2,
	SKILL = 3,
	TARGET = 4,
	OTHER = 5,
}

local PET_UNIT_STATUS = {
	INIT = 0,
	IDLE = 1,
	ACTIVE = 2,
	DEAD = 3,
	DUMB = 4,
}

SPECIAL_DEMON = {
	CAT = 1,
	CHEST = 2,
}

SpecialDemon.config = nil
SpecialDemon.smtype = nil
SpecialDemon.dumbRounds = 0
SpecialDemon.attackedTimes = 0

local specialUnitExplodeListener = nil

function SpecialDemon:getType()
	return self.smtype
end

function SpecialDemon:getAttackedTimes()
	if self.smtype == SPECIAL_DEMON.CHEST and self.attacked == 0 then
		self.attackedTimes = 2
	end
	return self.attackedTimes
end

function SpecialDemon:create(monsterId, index)
	local ret = SpecialDemon.new()
	ret:initAsDemon(monsterId, index)
	ret.config = ConfigManager.getSpecialMonsterConfig(monsterId)
	ret.smtype = ret.config.special_monster_type
	ret.dumbRounds = ret.config.rounds
	ret.status = PET_UNIT_STATUS.DUMB
	ret.attackedTimes = 0
	return ret
end

function SpecialDemon:initChestEvents()
	local customEvent = cc.EventCustom:new("event_generate_special_unit")
	customEvent._usedata = {stype=1, row=4, col=4}
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

	local sp = self.spine

	specialUnitExplodeListener = cc.EventListenerCustom:create("event_special_unit_explode", function(event)
		if event._usedata.unit.stype ~= 1 then
			return
		end

		if self.hpProgress then
			self.hpProgress:setVisible(false)
		end

		self.keyUnit = event._usedata.unit
        self.status = PET_UNIT_STATUS.DEAD
        MusicManager.chest_open()
		sp:setAnimation(ANIM_TYPE.PET, "open", false)
		sp:runAction(cc.Sequence:create(cc.DelayTime:create(4.0), cc.CallFunc:create(function()
			sp:removeFromParent()
			sp:release()
			self.spine = nil
		end)))
		self.shadow:setVisible(false)
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

		local customEvent = cc.EventCustom:new("event_unit_act")
		customEvent._usedata = {name="die", unit=self}
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

		self.attackedTimes = 1
    end)
    table.insert(self.eventListeners, specialUnitExplodeListener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(specialUnitExplodeListener, 1)
end

function SpecialDemon:start()
	local sp = self.spine
	local targetPos = cc.p(sp:getPosition())
	if self.smtype == SPECIAL_DEMON.CHEST then
		sp:setPosition(targetPos)
		sp:setVisible(false)
		sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			sp:setVisible(true)
			MusicManager.chest_drop()
			sp:setAnimation(ANIM_TYPE.PET, "drop", false)
			sp:addAnimation(ANIM_TYPE.PET, "keep", false)
		end)))

		self:initChestEvents()
	else
		local startPos = cc.p(targetPos.x + 200, targetPos.y)
		sp:setPosition(startPos)
		sp:setAnimation(ANIM_TYPE.PET, "walk", true)
		sp:addAnimation(ANIM_TYPE.PET, "breath", true, 0.5)
		sp:runAction(cc.MoveTo:create(0.5, targetPos))
	end
	self.shadow:setVisible(false)
	self.shadow:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		self.shadow:setVisible(true)
	end)))
end

function SpecialDemon:runAttackedAnim()
	self.spine:setAnimation(ANIM_TYPE.PET, "attacked", false)
	if self.smtype == SPECIAL_DEMON.CHEST then
		self.spine:addAnimation(ANIM_TYPE.PET, (self.status == PET_UNIT_STATUS.DUMB) and "keep" or "breath", true)
	else
		self.spine:addAnimation(ANIM_TYPE.PET, "breath", true)
	end

	-- 贪财猫掉金币
	if self.smtype == SPECIAL_DEMON.CAT then
		MusicManager.cat_attacked()
		local atlas = TextureManager.RES_PATH.SPINE_BATTLE_DROP_GOLD .. ".atlas"
		local json = TextureManager.RES_PATH.SPINE_BATTLE_DROP_GOLD .. ".json"
		local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		
		local customEvent = cc.EventCustom:new("event_battle_effect")
		customEvent._usedata = {}
		customEvent._usedata.effect = spine
		customEvent._usedata.pos = cc.p(self.layout:getPosition())
		customEvent._usedata.zorder = 10000
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

		spine:setAnimation(ANIM_TYPE.OTHER, "part1", false)
		spine:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
			spine:removeFromParent()
		end)))
		self.attackedTimes = self.attackedTimes + 1
	end
end

-- 权宜之计，用来在从消除阶段转战斗阶段时切换状态
function SpecialDemon:prepareToFight()
	print("special unit prepare to fight")
	if self.smtype == SPECIAL_DEMON.CAT and self.status ~= PET_UNIT_STATUS.DEAD then
		if self.livedRound == self.dumbRounds then
			self.status = PET_UNIT_STATUS.IDLE
		end
	elseif self.smtype == SPECIAL_DEMON.CHEST and self.status ~= PET_UNIT_STATUS.DEAD then
		if self.livedRound == self.dumbRounds - 1 then
			if (self.config.disappear == 0) then
				cc.Director:getInstance():getEventDispatcher():removeEventListener(specialUnitExplodeListener)
				self.status = PET_UNIT_STATUS.IDLE
				self.spine:setAnimation(ANIM_TYPE.PET, "monster", false)
				self.spine:addAnimation(ANIM_TYPE.PET, "breath", true)
				local customEvent = cc.EventCustom:new("event_unit_act")
				customEvent._usedata = {name="change", unit=self, stype = 1}
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			else
				self.status = PET_UNIT_STATUS.DEAD
				if self.hpProgress then
					self.hpProgress:setVisible(false)
				end
				cc.Director:getInstance():getEventDispatcher():removeEventListener(specialUnitExplodeListener)
				self.spine:setAnimation(ANIM_TYPE.PET, "disappear", false)
				self.spine:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
					self.spine:removeFromParent()
					self.spine:release()
					self.spine = nil
				end)))
				self.shadow:setVisible(false)
				self:removeAllBuffs()
				self:removeAllDebuffs()
				self:refreshBuffDebuffIcons()
				Utils.dispatchCustomEvent("event_unit_act", {name="die", unit=self, stype = 1})
			end
		end
	end
	if self.status == PET_UNIT_STATUS.DUMB then
		self.livedRound = self.livedRound + 1
	end
	return self.status == PET_UNIT_STATUS.DEAD
end

function SpecialDemon:activate()
	if self.smtype == SPECIAL_DEMON.CAT then
		self:removeAllDebuffs()
		self:removeAllBuffs()
		self.spine:setScaleX(-1)
		MusicManager.cat_run()
		self.spine:setAnimation(ANIM_TYPE.PET, "run", false)
		self.shadow:setVisible(false)
		self.layout:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(function()
			local pos = cc.p(self.layout:getPosition())
			pos.x = pos.x + 500
			self.layout:setPosition(pos)
			self:die()
			local customEvent = cc.EventCustom:new("event_unit_act")
			customEvent._usedata = {name="finish", unit=self}
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		end)))
		return false
	end
	self.status = PET_UNIT_STATUS.ACTIVE
	self.layout:setLocalZOrder(100)
	if self.spine:setAnimation(ANIM_TYPE.PET, self:getSkillAnimName("cast"), false) ~= 1 then
		self:finishCast()
	end
	return true
end

function SpecialDemon:isReady()
	local ready = (self.status == PET_UNIT_STATUS.IDLE) or (self.isPet and self.status ~= PET_UNIT_STATUS.ACTIVE)
	if not ready then
		return false
	end

	if self.smtype == SPECIAL_DEMON.CAT then
		return ready
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

function SpecialDemon:isAvailable()
	if self.smtype == SPECIAL_DEMON.CHEST then
 		return (self.status ~= PET_UNIT_STATUS.DEAD) and (self.status ~= PET_UNIT_STATUS.DUMB)
 	end
 	return self.status ~= PET_UNIT_STATUS.DEAD
 end