--
-- Author: hapigames
-- Date: 2014-11-26 12:21:57
--
require "view/tagMap/Tag_popup_bag_item_info"

IteminfoPopup = class("IteminfoPopup",function()
	return Popup:create()
end)

IteminfoPopup.__index = IteminfoPopup
local __instance = nil
local currentItem = nil
function IteminfoPopup:create()
	local ret = IteminfoPopup.new()
	__instance = ret
	if (ItemManager.currentItem ~= nil) then
		currentItem = ItemManager.currentItem
		ItemManager.currentItem = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function IteminfoPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function IteminfoPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_bag_item_info.PANEL_ITEM_INFO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function IteminfoPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_item_info",PATH_POPUP_BAG_ITEM_INFO)
	local btnClose = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.BTN_ITEM_SURE)
	btnClose:setOnClickScriptHandler(function() 
		Utils.popUIScene(self)
	end)
	local itemType,mid = currentItem:get("item_type"), currentItem:get("mid")
	local amount = ItemManager.getItemAmount(itemType, mid)
	local layout_item = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAYOUT_ITEM)
	local item = ItemManager.createItem(itemType,mid)
	local itemCell = ItemCell:create(itemType,item)
	Utils.addCellToParent(itemCell,layout_item,true)

	local itemName = TextManager.getItemName(itemType, mid)
	local lab_item_name = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAB_ITEM_NAME)
	lab_item_name:setString(itemName)
	local lab_own_num = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAB_OWN_NUM)
	lab_own_num:setString(amount)
	local lab_item_desc = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAB_ITEM_DESC)
	local itemDesc = TextManager.getItemDesc(itemType, mid)
	lab_item_desc:setString(itemDesc)

	local lab_sell_tip = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAB_SELL_TIP)
	local lab_sell_price = self:getControl(Tag_popup_bag_item_info.PANEL_ITEM_INFO,Tag_popup_bag_item_info.LAB_SELL_PRICE)
	local itemPrice = ConfigManager.getItemConfig(itemType, mid).sell_price
	if itemPrice == -1 then
		lab_sell_tip:setVisible(false)
		lab_sell_price:setVisible(false)
	else
		lab_sell_price:setString(itemPrice)
	end
	
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			WildDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			WildDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)

	TouchEffect.addTouchEffect(self)
end
