UnitBlock = class("UnitBlock")

UnitBlock.blockType = 0
UnitBlock.rounds = 0
UnitBlock.effect = nil
-- UnitBlock
UnitBlock.layers = 0

BLOCK_TYPE = {
	KEY = 1,
	ICE = 2,
}

function UnitBlock:init(block_type, rounds)
	self.blockType = block_type
	self.rounds = rounds

	local atlas = string.format(TextureManager.RES_PATH.SPINE_UNIT_BLOCK .. ".atlas", block_type)
	local json = string.format(TextureManager.RES_PATH.SPINE_UNIT_BLOCK .. ".json", block_type)
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setPosition(cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2))
    self.effect = spine
    self.layers = 1
    -- self.effect:retain()
    if block_type == 2 then
	    local customEvent = cc.EventCustom:new("event_block")
	    customEvent._usedata = block_type
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	end
end

function UnitBlock:create(block_type, rounds)
	local ret = UnitBlock.new()
	ret:init(block_type, rounds)
	return ret
end

function UnitBlock:show()
	self.effect:setAnimation(0, "show", false)
	self.effect:addAnimation(0, "normal", true, 0.833)
end

function UnitBlock:explode()
	self.layers = self.layers - 1
	if self.layers == 0 then
		self.effect:setAnimation(0, "disappear", false)
	end
end