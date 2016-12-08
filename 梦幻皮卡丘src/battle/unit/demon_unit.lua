require "manager/texturemanager"
require "common/spine"
require "common/debug"
require "view/tagMap/Tag_ui_battle"

DemonUnit = class("DemonUnit")

-- local constants
local DEMON_ACTIONS = {
	WALK = "walk",
	BREATH = "breath",
	CAST = "cast",
	ATTACK = "attack",
}

-- object variables
DemonUnit.mid = 0
DemonUnit.maxHP = 100
DemonUnit.curHP = 100
DemonUnit.isFinished = false
DemonUnit.layout = nil
DemonUnit.spine = nil
DemonUnit.index = 0

-- local functions
local DEMON_ACTIONS = {
	WALK = "walk",
	BREATH = "breath",
	CAST = "cast",
	ATTACK = "attack",
}

function DemonUnit:enter()
	local sp = self.spine
	local targetPos = cc.p(sp:getPosition())
	local startPos = cc.p(targetPos.x + 200, targetPos.y)
	sp:setPosition(startPos)
	sp:setAnimation(0, "walk", true)
	sp:addAnimation(0, "breath", true, 0.5)
	sp:runAction(cc.MoveTo:create(0.5, targetPos))
end

function DemonUnit:attacked(power)
	self.spine:setAnimation(0, "attacked", false)
	self.curHP = self.curHP - power
end

function DemonUnit:init(mid)
	local layout = CLayout:create()
	layout:retain()
	layout:setAnchorPoint(cc.p(0.5, 0))
	layout:setContentSize(cc.size(100, 100))
	self.layout = layout

	local shadow = TextureManager.createImg(TextureManager.RES_PATH.UNIT_SHADOW)
	shadow:setPosition(cc.p(50, 0))
	self.layout:addChild(shadow)

	local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, 172) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PET, 172) .. ".json"
	self.spine = sp.SkeletonAnimation:create(json, atlas, 1)
	self.spine:setAnimation(0, "breath", true)
	self.spine:setPosition(cc.p(50, 0))
	self.spine:setScaleX(-1)
	self.spine:setMix("walk", "breath", 0.2)
	self.layout:addChild(self.spine)
end

function DemonUnit:create(mid)
	local du = DemonUnit.new()
	du:init(mid)
	return du
end

function DemonUnit:cleanup()
	if self.layout and self.layout.release then
		self.layout:release()
	end
end