SpecialUnit = class("SpecialUnit", function()
	return EliminateUnit.new()
end)

local SPECIAL_UNIT_TYPE = {
	KEY = 1,
}

SpecialUnit.lastRounds = 2
SpecialUnit.stype = 0
SpecialUnit.colorType = 0

function SpecialUnit:init(stype)
	self.stype = stype
	local atlas = string.format(TextureManager.RES_PATH.SPINE_SPECIAL_UNIT .. ".atlas", stype)
	local json = string.format(TextureManager.RES_PATH.SPINE_SPECIAL_UNIT .. ".json", stype)
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
	spine:setAnimation(0, "normal", true)
    self:addChild(spine)
    self.spine = spine
    self.spine:retain()
	self:setAnchorPoint(cc.p(0, 0))
end

function SpecialUnit:create(stype)
	local ret = SpecialUnit.new()
	ret:init(stype)
	return ret
end

function SpecialUnit:explode()
end

function SpecialUnit:disappear()
	if self.isLoked then
		return
	end
	self.spine:setAnimation(0, "explode", false)
	self.spine:release()
	local event = cc.EventCustom:new("event_special_unit_explode")
	event._usedata = {unit=self}
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end