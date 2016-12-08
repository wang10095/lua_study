--
-- Author: hapigames
-- Date: 2014-12-09 12:17:19
--
require "view/tagMap/Tag_popup_bag_sellitem"

SellItemPopup = class("SellItemPopup",function()
	return Popup:create()
end)

SellItemPopup.__index = SellItemPopup
local __instance = nil
local currentItem = nil

function SellItemPopup:create()
	local ret = SellItemPopup.new()
	__instance = ret
	if ItemManager.currentItem ~=nil then
		currentItem = ItemManager.currentItem
		ItemManager.currentItem = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SellItemPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SellItemPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close( p_sender )
	Utils.popUIScene(__instance)
end



function SellItemPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_sellitem",PATH_POPUP_BAG_SELLITEM)
	local btnCancel = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.BTN_SELL_CANCEL)
	btnCancel:setOnClickScriptHandler(event_close)
	local itemLayout = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.LAYOUT_ITEM_SELLITEM)
	local itemtype,item = currentItem[1],currentItem[2]
	local itemCell =ItemCell:create(itemtype,item)
	Utils.addCellToParent(itemCell,itemLayout)

	local itemnameLab = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.LAB_ITEMNAME_SELLITEM)
	local name = TextManager.getItemName(itemtype,item:get("mid"))
	itemnameLab:setString(name)
	local itemAmountLab = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.LAB_ITEMNUM_SELLITEM)
	local amount = ItemManager.getItemAmount(itemtype,item:get("mid")) --当前拥有的材料数量
	itemAmountLab:setString(amount)

	local itemSellPrice = ConfigManager.getItemConfig(itemtype, item:get("mid")).sell_price    --物品卖出价格
	local sellAmount = 1
	local lab_goldnum = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.LAB_GOLDNUM)
	lab_goldnum:setString(math.abs(sellAmount*itemSellPrice))
	local btn_num1 = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.BTN_NUM1)
	local btn_num2 = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.BTN_NUM2)
	local lab_sell_num = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.LAB_SELL_NUM)
	lab_sell_num:setString(sellAmount)

	btn_num1:setOnClickScriptHandler(function()
		if sellAmount == 1 then
			return
		end
		sellAmount  = sellAmount - 1
		lab_sell_num:setString(sellAmount)
		lab_goldnum:setString(math.abs(sellAmount*itemSellPrice))
	end)

	btn_num2:setOnClickScriptHandler(function()
		if sellAmount >= amount then
			sellAmount = amount 
			return
		end
		sellAmount  = sellAmount + 1
		lab_sell_num:setString(sellAmount)
		lab_goldnum:setString(math.abs(sellAmount*itemSellPrice))
	end)

	local maxnumBtn = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.BTN_MAXNUM)
	maxnumBtn:setOnClickScriptHandler(function()
		sellAmount = amount
		lab_sell_num:setString(amount)
		lab_goldnum:setString(math.abs(amount*itemSellPrice))
	end)

	local function event_sellitem(p_sender)
		local function sellitem(result)
			if NormalDataProxy:getInstance().confirmHandler ~= nil then
				ItemManager.updateItem(result["item_type"],result["mid"],result["amount"])
				Player:getInstance():set("gold", result["gold"])
				NormalDataProxy:getInstance().confirmHandler()
				Utils.popUIScene(__instance)
				TipManager.showTip(name.."已出售，获得金币：".. tonumber(lab_sell_num:getString()) * itemSellPrice)
			end
			NormalDataProxy:getInstance().confirmHandler = nil
		end 
		print("num = "..tonumber(lab_sell_num:getString()))
		NetManager.sendCmd("sellitem",sellitem,itemtype,item:get("mid"),tonumber(lab_sell_num:getString()))
	end
	local sellBtn = self:getControl(Tag_popup_bag_sellitem.PANEL_POPUP_SELLITEM,Tag_popup_bag_sellitem.BTN_SELL)
	sellBtn:setOnClickScriptHandler(event_sellitem)
	TouchEffect.addTouchEffect(self)
end




