Item = class("Item", function()
    return Model:create("Item", {
        item_type = 0,
        mid = 0,
        amount = 0
    })
end
)

function Item:create(item_type, mid)
    local ret = Item:new()
    ret:set("item_type", item_type)
    ret:set("mid", mid)
    return ret
end

function Item:update(properties)
	if (properties["item_type"] ~= nil  and properties["item_type"] ~= self:get("item_type")) then
		return
	end

	if (properties["mid"] ~= nil and properties["mid"] ~= self:get("mid")) then
		return
	end

	for k,v in pairs(properties) do
		self:set(k, v)
	end
end