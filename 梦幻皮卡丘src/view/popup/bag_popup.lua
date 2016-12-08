--
-- Author: hapigames
-- Date: 2014-12-09 12:17:19
--
require "view/tagMap/Tag_popup_bag"

BagPopup = class("BagPopup",function()
	return Popup:create()
end)

BagPopup.__index = BagPopup
local __instance = nil
local list_  = nil
local items_ = nil
local item_types_ = nil

function BagPopup:create()
	local ret = BagPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BagPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BagPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_bag.PANEL_POPUP_BAG then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function callback_use_energy_potion(result)
	Player:getInstance():set("energy", result["energy"])
	ItemManager.updateItems({result["item"]})
	TipManager.showTip("使用体力药水成功")
	if NormalDataProxy:getInstance().updateUser ~= nil then
		NormalDataProxy:getInstance().updateUser() 
	end
end

function BagPopup:addItem(item)
	if item:get("amount") <= 0 then
		return
	end
	local pCell = CGridViewCell:new()
	TuiManager:getInstance():parseCell(pCell, "cell_itemlist", PATH_POPUP_BAG)
	list_:insertNodeAtLast(pCell)
	local index = list_:getNodeCount()
	-- local pCell = list_:getNodeAtIndex(i-1)
	local item_type = item:get("item_type")
	local itemLayout = pCell:getChildByTag(Tag_popup_bag.LAYOUT_ITEMLIST_PET)
	local itemCell =ItemCell:create(item_type,item)
	Utils.addCellToParent(itemCell,itemLayout)
	local itemnameLab = pCell:getChildByTag(Tag_popup_bag.LAB_ITEMLIST_ITEMNAME)
	local name = TextManager.getItemName(item_type,item:get("mid"))
	itemnameLab:setString(name)
	local itemNum = pCell:getChildByTag(Tag_popup_bag.LAB_ITEM_NUM2)
	local amount = ItemManager.getItemAmount(item_type, item:get("mid"))
	itemNum:setString(amount)
	local useBtn = pCell:getChildByTag(Tag_popup_bag.BTN_USEITEM)
	local sellBtn = pCell:getChildByTag(Tag_popup_bag.BTN_SELLITEM)
	local lab_useitem = pCell:getChildByTag(Tag_popup_bag.LAB_USEITEM)
	local lab_sellitem = pCell:getChildByTag(Tag_popup_bag.LAB_SELLITEM)
	local function eventUseItem ()
		ItemManager.currentItem = {item_type, item}
		if item_type == Constants.ITEM_TYPE.EXP_POTION then
			PetAttributeDataProxy:getInstance():set("useExpItem",item:get("mid"))
			Utils.runUIScene("UseItemPopup")
		elseif item_type == Constants.ITEM_TYPE.ENERGY_POTION then
			itemNum:setString(itemNum:getString()-1)
			NetManager.sendCmd("useEnergyPotion",callback_use_energy_potion,item:get("mid"))
			if tonumber(itemNum:getString())<=0 then
				list_:removeNodeAtIndex(index-1)
				list_:reloadData()
			end
		end
	end
	useBtn:setOnClickScriptHandler(eventUseItem)
	local function eventSellItem ()
		ItemManager.currentItem = {item_type, item}
		local function confirmHandler()
			__instance:loadAllItemsHandler()
		end
		NormalDataProxy:getInstance().confirmHandler = confirmHandler
		Utils.runUIScene("SellItemPopup")
	end
	sellBtn:setOnClickScriptHandler(eventSellItem)
	if item_type == Constants.ITEM_TYPE.ENERGY_POTION or item_type == Constants.ITEM_TYPE.EXP_POTION  then
		sellBtn:setVisible(false)
		lab_sellitem:setVisible(false)
	else
		useBtn:setVisible(false)
		lab_useitem:setVisible(false)
	end
	if item_type == Constants.ITEM_TYPE.MATERIAL then
		sellBtn:setVisible(false)
		lab_sellitem:setVisible(false)
		useBtn:setVisible(false)
		lab_useitem:setVisible(false)
	end

	local itemDesc = TextManager.getItemDesc(item_type, item:get("mid"))
	local lab_itemlist_itemdesc =  pCell:getChildByTag(Tag_popup_bag.LAB_ITEMLIST_ITEMDESC)
	lab_itemlist_itemdesc:setString(itemDesc)
end

function BagPopup:showItems()
	list_:removeAllNodes()
	items_ = {}

	for _, itemType in pairs(item_types_) do
		local itemsOfType = ItemManager.getItemsByType(itemType)
		if itemsOfType then
			for k,item in pairs(itemsOfType) do
				table.insert(items_, item)
			end
		end
	end

	-- 只显示前四条
	local num = #items_
	for i=1, num do
		self:addItem(items_[i])
	end
	list_:reloadData()
end

function BagPopup:loadAllItemsHandler()
	item_types_ = {2, 4, 5, 6, 7}
	self:showItems()
end

function BagPopup:loadTrainMateralHandler()
	item_types_ = {Constants.ITEM_TYPE.TRAIN_MATERIAL}
	self:showItems()
end

function BagPopup:loadEvolutionStoneHandler()
	item_types_ = {Constants.ITEM_TYPE.EVOLUTION_STONE}
	self:showItems()
end

function BagPopup:loadConsumableHandler()
	item_types_ = {5, 6}
	self:showItems()
end


local function event_close( p_sender )
	Utils.popUIScene(__instance)
end

function BagPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_bag",PATH_POPUP_BAG)

	local closeBtn = self:getControl(Tag_popup_bag.PANEL_POPUP_BAG,Tag_popup_bag.BTN_CLOSE)
	closeBtn:setOnClickScriptHandler(event_close)
	
	local tgvLayout = self:getControl(Tag_popup_bag.PANEL_POPUP_BAG,Tag_popup_bag.LAYOUT_TGV)
	list_ = self:getControl(Tag_popup_bag.PANEL_POPUP_BAG,Tag_popup_bag.LIST_BAG)

	local allTgv = tgvLayout:getChildByTag(Tag_popup_bag.TGV_ALL)
	allTgv:setOnClickScriptHandler(function() self:loadAllItemsHandler() end)
	allTgv:setChecked(true)
	
	local trainTgv = tgvLayout:getChildByTag(Tag_popup_bag.TGV_TRAIN)
	trainTgv:setOnClickScriptHandler(function() self:loadTrainMateralHandler() end)

	local evolutionTgv = tgvLayout:getChildByTag(Tag_popup_bag.TGV_EVOL)
	evolutionTgv:setOnClickScriptHandler(function() self:loadEvolutionStoneHandler() end)

	local consumableTgv = tgvLayout:getChildByTag(Tag_popup_bag.TGV_CONSUME)
	consumableTgv:setOnClickScriptHandler(function() self:loadConsumableHandler() end)

	self:loadAllItemsHandler()
	TouchEffect.addTouchEffect(self)

	local function onNodeEvent(event)
		if "enter"  == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
		elseif "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end
