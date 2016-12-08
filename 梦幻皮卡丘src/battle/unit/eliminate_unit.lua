EliminateUnit = class("EliminateUnit", function()
	return CLayout:create()
end)

-- local variables
local eUnit = nil

-- constants
EliminateUnit.SPECIAL_TYPE = {
	NONE = 0, 
	BOMB = 1,
	X_BOMB = 2,
	Y_BOMB = 3,
	SUPER_BOMB = 7,
}

-- object variables
EliminateUnit.index = 0
EliminateUnit.colorType = 1
EliminateUnit.colorIndex = 0
EliminateUnit.isLocked = false
EliminateUnit.isFinished = false
EliminateUnit.spine = nil
EliminateUnit.specialType = EliminateUnit.SPECIAL_TYPE.NONE
EliminateUnit.flag = false
EliminateUnit.eliminateNum = 0
EliminateUnit.changeTo = 0

EliminateUnit.blockUnit = nil
EliminateUnit.blocked = false

-- local functions 

function EliminateUnit:finish()
	if self.flag and self.changeTo > 0 then
			print("unit is going to change to", self.index, self.changeTo)
			self:removeAllChildren()
			self:initSpecial(self.colorType, self.colorIndex, self.changeTo)
			self.changeTo = 0
			self.flag = false
			self.isLocked = false
	else 
		self.isFinished = true
	end
end

-- object functions

function EliminateUnit:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_stage.PANEL_STAGE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function EliminateUnit:getControl(tagControl)
	return self:getChildByTag(tagControl)
end

function EliminateUnit:setColor(colorType, colorIndex)
	self.colorType = colorType
	self.colorIndex = colorIndex

	-- local square = cc.LayerColor:create(cc.c4b(255, 0, 0, 122), 78, 78)
	-- square:setPosition(cc.p(1, 1))
	-- self:addChild(square)
	local atlas = string.format(TextureManager.RES_PATH.SPINE_UNIT , colorType, colorIndex).. ".atlas"
	local json = string.format(TextureManager.RES_PATH.SPINE_UNIT , colorType, colorIndex).. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
    spine:setMix("normal", "selected", 0.1)
    spine:setMix("selected", "normal", 0.1)
	spine:setAnimation(0, "normal", true)
    self:addChild(spine)
    self.spine = spine
    self.spine:retain()
end

function EliminateUnit:init(colorType, colorIndex)
	self:setColor(colorType, colorIndex)
	self:setAnchorPoint(cc.p(0, 0))
end

function EliminateUnit:initSpecial(colorType, colorIndex, specialType)
	local atlas = ""
	local json = ""
    if specialType == EliminateUnit.SPECIAL_TYPE.BOMB or specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
    	atlas = TextureManager.RES_PATH.SPINE_UNIT_BOMB_EFFECT .. ".atlas"
    	json = TextureManager.RES_PATH.SPINE_UNIT_BOMB_EFFECT .. ".json"
    elseif specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB or specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB then
    	atlas = TextureManager.RES_PATH.SPINE_ELIMINATE_ARROW .. ".atlas"
    	json = TextureManager.RES_PATH.SPINE_ELIMINATE_ARROW .. ".json"
    end
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
    spine:setAnimation(0, "part1", true)
    self:addChild(spine)

    if specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB then
    	spine:setRotation(90)
    end
    if (specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB) then
    	self:setColor(colorType, EliminateUnit.SPECIAL_TYPE.SUPER_BOMB)
    else
    	self:setColor(colorType, colorIndex)
    end

	atlas = TextureManager.RES_PATH.SPINE_UNIT_SPARKLE .. ".atlas"
	json = TextureManager.RES_PATH.SPINE_UNIT_SPARKLE .. ".json"
    spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
	spine:setAnimation(0, "part1", true)
    self:addChild(spine)

    self:setAnchorPoint(cc.p(0, 0))

    self.specialType = specialType
end

function EliminateUnit:create(colorType, colorIndex)
	if (colorIndex == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB) then
		return EliminateUnit:createSpecialUnit(colorType, colorIndex, EliminateUnit.SPECIAL_TYPE.SUPER_BOMB)
	end
	local ret = EliminateUnit.new()
	ret:init(colorType, colorIndex)
	return ret
end

function EliminateUnit:createSpecialUnit(colorType, colorIndex, specialType)
	local ret = EliminateUnit.new()
	ret:initSpecial(colorType, colorIndex, specialType)
	return ret
end

function EliminateUnit:lock()
	self.isLocked = true
end

function EliminateUnit:unlock()
	self.isLocked = false
end

function EliminateUnit:select()
	self.spine:setAnimation(0, "selected", false)
end

function EliminateUnit:unselect()
	self.spine:setAnimation(0, "normal", true)
end

function EliminateUnit:explode(num)
	-- if num then
	-- 	self.eliminateNum = num
	-- end
	self:lock()


	if self.blocked then
		-- if self.blockUnit.block_type == BLOCK_TYPE.ICE then
			self.blockUnit:explode()
			if self.spine then
				self.spine:release()
				self.spine = nil
			end
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
				self:removeAllChildren()
				self:finish()
				-- self.blockUnit.effect:release()
			end)))
		-- end
		return
	end

	self.spine:release()
	self.spine = nil
	self:removeAllChildren()

	local atlas = TextureManager.RES_PATH.SPINE_UNIT_ELIMINATE .. ".atlas"
	local json = TextureManager.RES_PATH.SPINE_UNIT_ELIMINATE .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
	spine:setAnimation(0, "part1", false)
	spine:setTimeScale(0.66)
    self:addChild(spine)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
    	self:finish()
    end)))

    local event = cc.EventCustom:new("event_eliminate")
    event._usedata = self
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function EliminateUnit:block(btype, rounds)
	if self.blocked then
		return
	end

	if btype == BLOCK_TYPE.ICE then
		self.spine:setVisible(false)
	end

	self.blockUnit = UnitBlock:create(btype, rounds)
	self:addChild(self.blockUnit.effect)
	self.blockUnit:show()
	self.blocked = true
end