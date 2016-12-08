Fragment = class("Fragment", function()
    return Model:create("Fragment", {
        fgid = 0,
       	sell_price = 0, 
        pile_num = 0,
        quality = 0,
        sid = 0, -- source id
        drop_type = 0,
        drop_chapter= 0,
        drop_stage = 0,
        amount = 0
    })
end
)

function Fragment:create(fgidP)
	local ret = Fragment:new()
    ret.item_type = Constants.ITEM_TYPE.EXP_POTION
	print("Fragment create: "..fgidP)
	ret:init(fgidP)
	return ret
end

function Fragment:init(fgidP)
	fgidP = fgidP or 0
    self:set("fgid",fgidP)
	local FragmentTuple = ConfigManager.getConfig("fragment", "fragment", fgidP)
	if (FragmentTuple ~= nil) then
		self:set("sell_price", FragmentTuple.sell_price) 
		self:set("pile_num", FragmentTuple.pile_num)
		self:set("quality",FragmentTuple.quality)
		self:set("sid",FragmentTuple.sid)
		self:set("drop_type",FragmentTuple.drop_type)
		self:set("drop_chapter",FragmentTuple.drop_chapter)
		self:set("drop_stage",FragmentTuple.drop_stage)
	end
end

function Fragment:update()
	if (self.target ~= nil and self.updateFunc ~= nil) then 
	    print("update with params: self object"..tostring(self.target))
	    self.updateFunc(self.target, self)
  	end
end

function Fragment:getNameString()
    local id = self:get("fgid")
    local tuple = ConfigManager.getConfig("fragment", "fragment", id)
	local quality = tuple.quality
    local tupleQuality = ConfigManager.getConfig("quality", "quality", quality)
    local subQuality = string.sub(tupleQuality.source, -1, -1)
    local nameStr = tuple.name
    if (tonumber(subQuality) > 0) then
        nameStr = nameStr..'+'..subQuality
    end
    local color = cc.c3b(tupleQuality.font_color[1],tupleQuality.font_color[2],tupleQuality.font_color[3])
    return nameStr, color
end
