--
-- Author: hapigames
-- Date: 2014-11-26 12:21:57
--
require "view/tagMap/Tag_popup_buypopup"

BuyPopup = class("BuyPopup",function()
	return Popup:create()
end)

BuyPopup.__index = BuyPopup
local __instance = nil
local items = nil
function BuyPopup:create()
	local ret = BuyPopup.new()
	__instance = ret
	if (ItemManager.currentItem ~= nil) then
		items = ItemManager.currentItem
		ItemManager.currentItem = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BuyPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BuyPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_buypopup.PANEL_BUYPOPUP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BuyPopup:updateUI()
	TupleFood = ConfigManager.getConfig("food", "food", fid)
end

local function event_popup_close( )
	
end

function BuyPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_buypopup",PATH_POPUP_BUYPOPUP)
	local function event_close( p_sender )
		Utils.popUIScene(self)
	end
	local btnClose = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)

	local shopdataproxy = Shopdataproxy:getInstance()
	itemtype,mid,aptitude,goodsID = shopdataproxy:get("item_type"),shopdataproxy:get("mid"),shopdataproxy:get("aptitude"),shopdataproxy:get("goods_id")

	local shoptype = Shopdataproxy:getInstance():get("shop_type")
	local goldtype = Shopdataproxy:getInstance():get("goodType")
    local moneyType = {"diamond","gold","fame","badge"}
    local tipString = {"钻石不足","金币不足","声望不足","徽章不足"}
	local img_money = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.IMG_MONEY)
	imgMoneyTale = {"diamond","gold","prestige","badge"} 
	img_money:setSpriteFrame("component_common/img_" .. imgMoneyTale[goldtype] .. ".png")
	if goldtype >2 then
		img_money:setScale(0.5)
	end
	local newPet = true
	local function event_function( p_sender ) 
		if Player:getInstance():get(moneyType[goldtype]) < Shopdataproxy:getInstance():get("item_price")  then
			if goldtype==1 then
				Utils.useRechargeDiamond()
			elseif goldtype == 2 then
				Utils.useGoldhand()
			else
				TipManager.showTip(tipString[goldtype])
			end
			return
		end
		local function onBuyItem(result) 
			local moneyType = {"diamond","gold","fame","badge"}
		    Player:getInstance():set(moneyType[result["moneytype"]],result["moneynum"])
			local item = result["item"]
			local pet = result["pet"]
			if itemtype == 1 then
				local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
				for i,v in pairs(petContent) do
					if v:get("mid") == pet.mid and v:get("form") == pet.form then
						newPet = false
						break
					end
				end
				if newPet then
					GuideManager.guide_pet = 0
					WildDataProxy:getInstance():set("newPet_mid",pet.mid)
					WildDataProxy:getInstance():set("newPet_form",pet.form)
					if NormalDataProxy:getInstance().confirmHandler then
						NormalDataProxy:getInstance().confirmHandler = nil
					end
					NormalDataProxy:getInstance().confirmHandler = function()
						event_popup_close()
					end
					Utils.runUIScene("NewPetPopup")
				end
				ItemManager.addPet(pet)
			else
				ItemManager.updateItem(item.item_type,item.mid,item.amount)
			end
			local eventDispatcher = __instance:getEventDispatcher()
			local event = cc.EventCustom:new("game_custom_event1")
			eventDispatcher:dispatchEvent(event)
			Utils.popUIScene(__instance)
		end

		NetManager.sendCmd("buyitem", onBuyItem, goodsID,shoptype)
	end
	local btn_buy = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.BTN_BUY)
	btn_buy:setOnClickScriptHandler(event_function)
	local layoutGoods = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.LAYOUT_BUYPOPUP_ICON)

	if itemtype == 1 then --宠物
		local pet = Pet:create()
		pet:set("mid",mid)
		pet:set("form",1)
		pet:set("star",1)
		pet:set("aptitude",aptitude)
		local petCell = PetCell:create(pet)
		Utils.addCellToParent(petCell,layoutGoods)
	else  --物品
		local item = ItemManager.createItem(itemtype,mid)
		local cell = ItemCell:create(itemtype,item)
		Utils.addCellToParent(cell,layoutGoods)
		print("==item cell===" .. itemtype,mid)
	end
	
	local lab_pet_name = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.LAB_PET_NAME)
	if itemtype == 1 then
		local name = TextManager.getPetName(mid,1)
		lab_pet_name:setString(name)
	else
		local name = TextManager.getItemName(itemtype,mid)
		lab_pet_name:setString(name)
	end
	local lab_item_num = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP, Tag_popup_buypopup.LAB_ITEM_NUM)
	if itemtype ~=1 then
		lab_item_num:setString(ItemManager.getItemAmount(itemtype, mid))
	else
		lab_item_num:setVisible(false)
		local lab_num_1 = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP, Tag_popup_buypopup.LAB_NUM_1)
		lab_num_1:setVisible(false)
	end
	
	local lab_item_desc = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.LAB_ITEM_DESC)
	if itemtype == 1 then
		lab_item_desc:setString(TextManager.getPetDesc(mid,1))
	else
		lab_item_desc:setString(TextManager.getItemDesc(itemtype, mid))
	end

	local lab_price = self:getControl(Tag_popup_buypopup.PANEL_BUYPOPUP,Tag_popup_buypopup.LAB_PRICE)
	lab_price:setString(Shopdataproxy:getInstance():get("item_price"))
	-- self:updateUI()
	TouchEffect.addTouchEffect(self)

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
			Shopdataproxy:getInstance():set("isRecharge",true)
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
			Shopdataproxy:getInstance():set("isRecharge",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end








