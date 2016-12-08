require "view/tagMap/Tag_cell_item"

ItemCell= class("ItemCell",function()
	return CGridViewCell:new()
end)

ItemCell.__index = ItemCell
--be careful to use local variable in class, 
--those local variables just refer to the last variable it assigned
local __instance = nil

function ItemCell:registerItem(itemP)
	if (itemP ~= nil) then
		-- print("register ItemCell updateFunc"..tostring(self))
 		-- itemP:setUpdate(self,ItemCell.updateUI)
 		self:updateUI(itemP)
 	end
end

function ItemCell:create(itemtype, item)
	local ret = ItemCell.new()
	__instance = ret
	TuiManager:getInstance():parseCell(__instance,"cell_item",PATH_CELL_ITEM)
	__instance:init(itemtype)
	__instance:registerItem(item)
	__instance:updateUI(item)
	return ret
end

function ItemCell:getControl(tagControl)
	local ret = nil
	ret = self:getChildByTag(tagControl)
	return ret
end

function ItemCell:updateUI(itemP)
	-- print("item_type: "..self.itemType.." updateUI item id: "..itemP:get(Constants.ITEM_TYPE_ID[self.itemType]))
	local id = itemP:get("mid")
	local updateItemFunc = {
		[Constants.ITEM_TYPE.MATERIAL] = function ()
			-- print(pid.."_"..star.."_"..quality.."&"..subquality)
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)
				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
			
				local tupleBorder = TextManager.getItemQuality(item_type,mid)
				
				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
					-- local texture = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileName):getTexture()
					-- self.layoutItem:setTexture(fileName)
				end

				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
					-- self.layoutBorder:setSpriteFrame(fileName)
				end
			end
		end,

		[Constants.ITEM_TYPE.EXP_POTION] = function ()
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)

				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
			
				local tupleBorder = TextManager.getItemQuality(item_type,mid)
				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
						-- self.layoutItem:setTexture(fileName)
				end

				
				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
				end
			end
		end,

		[Constants.ITEM_TYPE.TREASURE_CHEST] = function ()
			-- print(pid.."_"..star.."_"..quality.."&"..subquality)
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)

				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
			
				local tupleBorder = TextManager.getItemQuality(item_type,mid)
			
				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
				end

				
				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
				end
			end
		end,

		[Constants.ITEM_TYPE.EVOLUTION_STONE] = function ()
			-- print(pid.."_"..star.."_"..quality.."&"..subquality)
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)

				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
			
				local tupleBorder = TextManager.getItemQuality(item_type,mid)
				tupleBorder = 6 --进化石用红色边框
				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
				end

				
				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
				end
			end
		end,

		[Constants.ITEM_TYPE.ENERGY_POTION] = function ()
			-- print(pid.."_"..star.."_"..quality.."&"..subquality)
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)

				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
				local tupleBorder = TextManager.getItemQuality(item_type,mid)
				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
				end
				
				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
				end
			end
		end,

		[Constants.ITEM_TYPE.TRAIN_MATERIAL] = function ()
			-- print(pid.."_"..star.."_"..quality.."&"..subquality)
			if (id == 0) then
				-- self:setVisible(false)
				self:setVisible(true)
			else
				self:setVisible(true)

				local mid = itemP:get("mid")
				local item_type = itemP:get("item_type")
			
				local tupleBorder = TextManager.getItemQuality(item_type,mid)

				if (id ~= 0 and self.layoutItem ~= nil) then
					local fileName =TextureManager.createImg(string.format(TextureManager.RES_PATH.ITEM_IMAGE, itemP:get("item_type"),itemP:get("mid"))) 
					Utils.addCellToParent(fileName,self.layoutItem)
				end
				
				if (tupleBorder ~= nil and self.layoutBorder ~= nil) then
					local fileName = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER, tupleBorder))
					Utils.addCellToParent(fileName,self.layoutBorder)
				end
			end
		end
	}
	if updateItemFunc[self.itemType] then
		updateItemFunc[self.itemType](id)
	else
		print("no update function for item ", self.itemType)
		updateItemFunc[self.itemType](id)
	end
end

function ItemCell:getQuality()
	return self.quality
end

function ItemCell:setTouchBeganNormalHandler(touchBeganHandlerP)
	self.touchBeganHandler = touchBeganHandlerP
end

function ItemCell:setTouchEndedNormalHandler(touchEndedHandlerP)
	self.touchEndedHandler = touchEndedHandlerP
end

function ItemCell:setTouchBeganClosureHandler(touchBeganHandlerP)
	--the format of the handler must be a closure 
	self.touchBeganHandler = touchBeganHandlerP()
end

function ItemCell:setTouchEndedClosureHandler(touchEndedHandlerP)
	self.touchEndedHandler = touchEndedHandlerP()
end

function ItemCell:addDefaultTouchEvent()
	local function onTouchBegan(p_sender, touch)
		if (self.touchBeganHandler ~= nil)   then
			self.touchBeganHandler()
		end
			
		return Constants.TOUCH_RET.TRANSIENT
	end

	local function onTouchEnded(p_sender, touch, duration)
		if (self.touchEndedHandler ~= nil) then
			self.touchEndedHandler()
		end
		return Constants.TOUCH_RET.TRANSIENT
	end

	self:setOnTouchBeganScriptHandler(onTouchBegan)
	self:setOnTouchEndedScriptHandler(onTouchEnded)

	-- local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
	-- listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
	-- local eventDispatcher = self:getEventDispatcher() -- 时间派发器 
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function ItemCell:init(itemtypeP)
	self.layoutItem = self:getControl(Tag_cell_item.LAYOUT_ITEM)
	self.layoutBorder = self:getControl(Tag_cell_item.LAYOUT_BORDER)
	self.itemType = itemtypeP
	self:addDefaultTouchEvent()

	self.layout_effect_up = self:getControl(Tag_cell_item.LAYOUT_EFFECT_UP)
	self.layout_effect_down = self:getControl(Tag_cell_item.LAYOUT_EFFECT_DOWN)
end
