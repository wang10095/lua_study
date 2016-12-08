--
-- Author: hapigames
-- Date: 2014-11-24 21:25:05
--
require "view/tagMap/Tag_ui_shop"

ShopUI = class("ShopUI",function()
	return TuiBase:create()
end)

ShopUI.__index = ShopUI
local __instance = nil
local buyItemListner = nil
local lab_player_diamond_num,lab_player_gold_num
local lab_remaintime

function ShopUI:create()
	local ret = ShopUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ShopUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ShopUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_shop.PANEL_SHOP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function ShopUI:dtor()
	self:getEventDispatcher():removeEventListener(self.listener1)
	self:getEventDispatcher():removeEventListener(self.listener2)
end

local function onTagClicked(p_sender)
	local tag = p_sender:getTag()
	local k = {
		Tag_ui_shop.TGV_COMMON_1,
		Tag_ui_shop.TGV_COMMON_2,
		Tag_ui_shop.TGV_COMMON_3
	}
	for i=1,#k do
		-- TextureManager.changeLabColor(k[i],tag,lab)
	end
end

function ShopUI:updateShopGV()
	lab_player_diamond_num:setString(Player:getInstance():get("diamond"))
	lab_player_gold_num:setString(Player:getInstance():get("gold"))
	goodslist = Shopdataproxy.goodsList
	local shoptype = Shopdataproxy:getInstance():get("shop_type")
	local imgBg = __instance:getControl(Tag_ui_shop.PANEL_SHOP,Tag_ui_shop.IMG9_SHOW_BG)
	local gv_shop = __instance:getControl(Tag_ui_shop.PANEL_SHOP,Tag_ui_shop.GV_SHOP)
	local Pos1 = cc.p(imgBg:getPosition())
	if shoptype == Constants.SHOP_TYPE.BADGE_SHOP or shoptype == Constants.SHOP_TYPE.PRESTIGE_SHOP  then
        gv_shop:setPosition(cc.p(Pos1.x,Pos1.y+40))
	end
	
	if Shopdataproxy:getInstance():get("shop_type") == Constants.SHOP_TYPE.BADGE_SHOP then --徽章
		lab_player_gold_num:setString(Player:getInstance():get("badge"))
	elseif Shopdataproxy:getInstance():get("shop_type") == Constants.SHOP_TYPE.PRESTIGE_SHOP then
		lab_player_gold_num:setString(Player:getInstance():get("fame"))
	end
	
	local function updateshopgv(p_convertview, idx)
		local pCell = nil
		pCell = p_convertview

		-- if pCell == nil then
			local goodsid,item_type,mid,amount,goldtype, price,isbuy=goodslist[idx+1].goods_id, goodslist[idx+1].item_type,goodslist[idx+1].mid,goodslist[idx+1].amount, goodslist[idx+1].diamond_type,goodslist[idx+1].diamond,goodslist[idx+1].isbuy			
			pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell,"cell_shop",PATH_UI_SHOP)
			local layout_good = pCell:getChildByTag(Tag_ui_shop.LAYOUT_GOODS)
			local layout_pet = layout_good:getChildByTag(Tag_ui_shop.LAYOUT_PET)
		
			local img_prestige = layout_good:getChildByTag(Tag_ui_shop.IMG_PRESTIGE_ICON)
			local img_badge = layout_good:getChildByTag(Tag_ui_shop.IMG_BADGE_ICON)
			local img_gold = layout_good:getChildByTag(Tag_ui_shop.IMG_GOLD)
			local img_diamond = layout_good:getChildByTag(Tag_ui_shop.IMG_DIAMOND_ICON)
			local labGold = layout_good:getChildByTag(Tag_ui_shop.LAB_GOLD)
			local img9bg = layout_good:getChildByTag(Tag_ui_shop.IMG9_GOLD_PRICE_BG)
			local labAmount = layout_good:getChildByTag(Tag_ui_shop.LAB_GOODS_AMOUNT)
			img_badge:setScale(0.8)
			img_prestige:setScale(0.8)
			if item_type == 1 then --宠物
				local pet = Pet:create()
				pet:set("mid",mid)
				pet:set("form",1)
				pet:set("star",1)
				pet:set("aptitude",amount)
				local petCell = PetCell:create(pet)
				Utils.addCellToParent(petCell,layout_pet,true)
				labAmount:setString(1)
			else  --物品
				local item = ItemManager.createItem(item_type, mid)
				local itemcell = ItemCell:create(item_type,item)
				Utils.addCellToParent(itemcell,layout_pet,true)
				labAmount:setString(amount)
			end
			local labName = layout_good:getChildByTag(Tag_ui_shop.LAB_ITEM_NAME)
			if item_type == 1 then
				local name = TextManager.getPetName(mid,1)
				labName:setString(name)
			else
				local name = TextManager.getItemName(item_type,mid)
				labName:setString(name)
			end
			
			local item_price = layout_good:getChildByTag(Tag_ui_shop.LAB_GOLD)
			item_price:setString(price)
			
			if goldtype == 1 then --钻石
				img_gold:setVisible(false)
				img_prestige:setVisible(false)
				img_diamond:setVisible(true)
				img_badge:setVisible(false)
			elseif goldtype == 2 then --金币
				img_diamond:setVisible(false)
				img_prestige:setVisible(false)
				img_badge:setVisible(false)
				img_gold:setVisible(true)
			elseif goldtype == 3 then --声望
				img_gold:setVisible(false)
				img_diamond:setVisible(false)
				img_prestige:setVisible(true)
				img_badge:setVisible(false)
			elseif goldtype == 4 then --徽章
				img_gold:setVisible(false)
				img_diamond:setVisible(false)
				img_prestige:setVisible(false)
				img_badge:setVisible(true)
			end
			
			local imgSellOut = layout_good:getChildByTag(Tag_ui_shop.IMG_SELL_OUT)
			imgSellOut:setVisible(false)
			if isbuy ~= 0 then
				item_price:setVisible(false)
				img_gold:setVisible(false)
				local img9bg = layout_good:getChildByTag(Tag_ui_shop.IMG9_GOLD_PRICE_BG)
				img9bg:setVisible(false)
				imgSellOut:setVisible(true)
				img_diamond:setVisible(false)
				img_prestige:setVisible(false)
				img_badge:setVisible(false)
			end
						
			local function onloadBuyItemHandler()
				if isbuy == 0 then
					local shoptype = Shopdataproxy:getInstance():get("shop_type")
					local function event_changeGoodsState()
						isbuy = 1
						labGold:setVisible(false)
						-- local img_gold = layout_good:getChildByTag(Tag_ui_shop.IMG_GOLD)
						img_gold:setVisible(false)
						-- local img_diamond = layout_good:getChildByTag(Tag_ui_shop.IMG_DIAMOND_ICON)
						img_diamond:setVisible(false)
						
						img9bg:setVisible(false)
						imgSellOut:setVisible(true)

						if goldtype == 1 then --钻石
							lab_player_diamond_num:setString(Player:getInstance():get("diamond"))
						elseif goldtype == 2 then --金币
							lab_player_gold_num:setString(Player:getInstance():get("gold"))
						elseif goldtype == 3 then --声望
							lab_player_gold_num:setString(Player:getInstance():get("fame"))
						elseif goldtype == 4 then --徽章
							lab_player_gold_num:setString(Player:getInstance():get("badge"))
						end
					end
					Shopdataproxy:getInstance():set("item_type",item_type)
					Shopdataproxy:getInstance():set("mid",mid)
					Shopdataproxy:getInstance():set("aptitude",amount)
					Shopdataproxy:getInstance():set("goods_id",goodsid)
					Shopdataproxy:getInstance():set("item_price",price)
					Shopdataproxy:getInstance():set("goodType",goldtype)
					Utils.runUIScene("BuyPopup")
					if __instance.listener2 then
						__instance:getEventDispatcher():removeEventListener(__instance.listener2)
						__instance.listener2= nil
					end
					local listener2 = cc.EventListenerCustom:create("game_custom_event1",event_changeGoodsState)
				    __instance.listener2 = listener2
				    local eventDispatcher = __instance:getEventDispatcher()
				    eventDispatcher:addEventListenerWithFixedPriority(listener2, 1)
				else
					local msg = "点击刷新之后才可以购买该物品！"
        			TipManager.showTip(msg)
        		end
				return true
			end

			local noMove  = true
			local xx,yy = nil
			local function onTouchBegan(p_sender, touch)
				local selfLocation = gv_shop:convertTouchToNodeSpace(touch)
				local location  = layout_good:convertTouchToNodeSpace(touch)
				local size = layout_good:getContentSize()
				xx,yy = selfLocation.x,selfLocation.y
				local rect = cc.rect(0,0,size.width,size.height)
				if NormalDataProxy:getInstance():get("isPopup") == false and cc.rectContainsPoint(rect, location) then
					noMove = true
					layout_good:setScale(0.95);
				end
					
				return Constants.TOUCH_RET.TRANSIENT
			end
			local function onTouchMoved( p_sender,touch )

				local location = layout_good:convertTouchToNodeSpace(touch)
				local distanceX,distanceY = math.floor(location.x-xx),math.floor(location.y-yy)
				if not (math.abs(distanceX) < 30 and math.abs(distanceY) < 30) then
					noMove = false
					layout_good:setScale(1)
				end
				return Constants.TOUCH_RET.TRANSIENT
			end
			local function onTouchEnded(p_sender, touch, duration)
				layout_good:setScale(1)
				-- if noMove == true and NormalDataProxy:getInstance():get("isPopup") == false  then
					onloadBuyItemHandler()
				-- end
				noMove = true
				return Constants.TOUCH_RET.TRANSIENT
			end

			layout_good:setOnTouchBeganScriptHandler(onTouchBegan)
			layout_good:setOnTouchMovedScriptHandler(onTouchMoved)
			layout_good:setOnTouchEndedScriptHandler(onTouchEnded)
		
		return pCell
	end
	gv_shop:setDataSourceAdapterScriptHandler(updateshopgv)
	gv_shop:setCountOfCell(#goodslist)
	gv_shop:setDragable(false)
	gv_shop:reloadData()
end

function ShopUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_shop",PATH_UI_SHOP)
	local layoutTop = self:getControl(Tag_ui_shop.PANEL_SHOP,Tag_ui_shop.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)
	
	local layoutBottom = self:getControl(Tag_ui_shop.PANEL_SHOP,Tag_ui_shop.LAYOUT_BOTTOM)
	Utils.floatToBottom(layoutBottom)
	lab_remaintime = layoutBottom:getChildByTag(Tag_ui_shop.LAB_REMAINTIME)
	local labGoldType = layoutBottom:getChildByTag(Tag_ui_shop.LAB_GOLDTYPE_REFRESH)
	tgvAll = self:getControl(Tag_ui_shop.PANEL_SHOP,Tag_ui_shop.LAYOUT_FUNCTION)

	local imgNpc = layoutTop:getChildByTag(Tag_ui_shop.IMG_NPC)
	imgNpc:retain()
	local labTalk = layoutTop:getChildByTag(Tag_ui_shop.LAB_TALK)
	labTalk:setString("")

    if Shopdataproxy:getInstance():get("shop_type") < 4 then
    	NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.NormalShop)
  		NpcTalkManager.setNPCTouch(self,imgNpc,labTalk,NpcTalkManager.SCENE.NormalShop)
  	else
  		NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.SuperShop)
  		NpcTalkManager.setNPCTouch(self,imgNpc,labTalk,NpcTalkManager.SCENE.SuperShop)
  	end
    local menuConfig = ConfigManager.getMenushopConfig(1)
    local date = os.date("%H")
    if tonumber(date)<menuConfig.time[1] then
    	lab_remaintime:setString(menuConfig.time[1] .. ":00自动刷新")
    elseif tonumber(date)>=menuConfig.time[1] and tonumber(date)<menuConfig.time[2] then
    	lab_remaintime:setString(menuConfig.time[2] .. ":00自动刷新")
    elseif tonumber(date)>=menuConfig.time[2] then
    	lab_remaintime:setString("明日" .. menuConfig.time[1] .. ":00自动刷新")
    end
	img_energy_bg2 = layoutTop:getChildByTag(Tag_ui_shop.IMG_ENERGY_BG2)
	img_shop_diamond = layoutTop:getChildByTag(Tag_ui_shop.IMG_SHOP_DIAMOND)
	lab_player_diamond_num = layoutTop:getChildByTag(Tag_ui_shop.LAB_PLAYER_DIAMOND_NUM)
	lab_player_diamond_num:setString(Player:getInstance():get("diamond"))
	local function updateDiamond()
		if lab_player_diamond_num then
			lab_player_diamond_num:setString(Player:getInstance():get("diamond"))
		end
	end
	self.listenerDiamond = cc.EventListenerCustom:create("recharge_update_diamond",updateDiamond)
    local eventDispatcher = __instance:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerDiamond, 1)

	lab_player_gold_num = layoutTop:getChildByTag(Tag_ui_shop.LAB_PLAYER_GOLD_NUM)
	lab_player_gold_num:setString(Player:getInstance():get("gold"))
	if Shopdataproxy:getInstance():get("shop_type")<4 then
		local function updateGold()
			if lab_player_gold_num then
				lab_player_gold_num:setString(Player:getInstance():get("gold"))
			end
		end
	    self.listenerGold = cc.EventListenerCustom:create("recharge_update_gold",updateGold)
	    local eventDispatcher = __instance:getEventDispatcher()
	    eventDispatcher:addEventListenerWithFixedPriority(self.listenerGold, 1)
	end

	img_shop_gold = layoutTop:getChildByTag(Tag_ui_shop.IMG_SHOP_GOLD)
	if Shopdataproxy:getInstance():get("shop_type") == Constants.SHOP_TYPE.BADGE_SHOP then --徽章
		local menuConfig = ConfigManager.getMenushopConfig(Constants.SHOP_TYPE.BADGE_SHOP)
		lab_remaintime:setString("每日" .. menuConfig.time .. ":00自动刷新")
		img_energy_bg2:setVisible(false)
		img_shop_diamond:setVisible(false)
		lab_player_diamond_num:setVisible(false)
		lab_player_gold_num:setString(Player:getInstance():get("badge"))
		img_shop_gold:setSpriteFrame("component_common/img_badge.png")
		img_shop_gold:setPositionY(img_shop_gold:getPositionY()-3)
		lab_player_gold_num:setPositionX(lab_player_gold_num:getPositionX()+20)
	elseif Shopdataproxy:getInstance():get("shop_type") == Constants.SHOP_TYPE.PRESTIGE_SHOP then
		local menuConfig = ConfigManager.getMenushopConfig(Constants.SHOP_TYPE.PRESTIGE_SHOP)
		lab_remaintime:setString("每日" .. menuConfig.time .. ":00自动刷新")
		img_energy_bg2:setVisible(false)
		img_shop_diamond:setVisible(false)
		lab_player_diamond_num:setVisible(false)
		lab_player_gold_num:setString(Player:getInstance():get("fame"))
		img_shop_gold:setSpriteFrame("component_common/img_prestige.png")
		img_shop_gold:setPositionY(img_shop_gold:getPositionY()+10)
		lab_player_gold_num:setPositionX(lab_player_gold_num:getPositionX()+20)
	end


	local shoptype = Shopdataproxy:getInstance():get("shop_type")
	if shoptype == Constants.SHOP_TYPE.BADGE_SHOP then
		tgvAll:setVisible(false)
	elseif shoptype == Constants.SHOP_TYPE.PRESTIGE_SHOP then
		tgvAll:setVisible(false)
	end

	tgvNormal = tgvAll:getChildByTag(Tag_ui_shop.TGV_COMMON_1)
	tgvSuperVip = tgvAll:getChildByTag(Tag_ui_shop.TGV_COMMON_2)
	tgvDiamondVip = tgvAll:getChildByTag(Tag_ui_shop.TGV_COMMON_3)
	tgvNormal:setChecked(true)
	local advanced_level = ConfigManager.getShopCommonConfig("advanced_level")
	local advanced_vip = ConfigManager.getShopCommonConfig("advanced_vip")
	local diamond_vip = ConfigManager.getShopCommonConfig("diamond_vip") 

	local nowtgv = 1
	local function changeTgv(tgv)
		tgvNormal:setChecked(tgv == 1)
		tgvSuperVip:setChecked(tgv == 2)
		tgvDiamondVip:setChecked(tgv == 3)
	end

	tgvNormal:setOnClickScriptHandler(function()
		if nowtgv == 1 then
			changeTgv(1)
			return
		end
	    local menuConfig = ConfigManager.getMenushopConfig(1)
	    local date = os.date("%H")
	    if tonumber(date)<menuConfig.time[1] then
	    	lab_remaintime:setString(menuConfig.time[1] .. ":00自动刷新")
	    elseif tonumber(date)>=menuConfig.time[1] and tonumber(date)<menuConfig.time[2] then
	    	lab_remaintime:setString(menuConfig.time[2] .. ":00自动刷新")
	    elseif tonumber(date)>=menuConfig.time[2] then
	    	lab_remaintime:setString("明日" .. menuConfig.time[1] .. ":00自动刷新")
	    end
		Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.NORMAL_SHOP)
		local function loadNormalshop( result )
			Shopdataproxy.goodsList = result["list"]
			Shopdataproxy.refreshList[Constants.SHOP_TYPE.NORMAL_SHOP] = result["refreshTimes"]
			self:updateShopGV() 
		end
		NetManager.sendCmd("loadbuylist",loadNormalshop,Constants.SHOP_TYPE.NORMAL_SHOP)
		changeTgv(1)
		nowtgv = 1
	end)
	
	tgvSuperVip:setOnClickScriptHandler(function( )
		if nowtgv == 2 then
			changeTgv(2)
			return
		end
		local menuConfig = ConfigManager.getMenushopConfig(2)
	    lab_remaintime:setString("每日" .. menuConfig.time .. ":00自动刷新")
		local vip = Player:getInstance():get("vip")
		if vip >= advanced_vip then
			Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.ADVANCED_SHOP)
			local function loadadvancedshop( result )
				Shopdataproxy.goodsList = result["list"]
				Shopdataproxy.refreshList[Constants.SHOP_TYPE.ADVANCED_SHOP] = result["refreshTimes"]
				self:updateShopGV() 
			end
			NetManager.sendCmd("loadbuylist",loadadvancedshop,Constants.SHOP_TYPE.ADVANCED_SHOP)
			changeTgv(2)
			nowtgv = 2
		else
			local msg = "您未达到开启等级，请尽快升级vip等级！"
        	TipManager.showTip(msg)
        	changeTgv(nowtgv)
		end
	end)
	tgvDiamondVip:setOnClickScriptHandler(function( )
		if nowtgv == 3 then
			changeTgv(3)
			return
		end
		local menuConfig = ConfigManager.getMenushopConfig(3)
	    lab_remaintime:setString("每日" .. menuConfig.time .. ":00自动刷新")
		local vip = Player:getInstance():get("vip")
		if vip >= diamond_vip then
			Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.DIAMOND_SHOP)
			local function loaddiamondshop( result )
				Shopdataproxy.goodsList = result["list"]
				Shopdataproxy.refreshList[Constants.SHOP_TYPE.DIAMOND_SHOP] = result["refreshTimes"]
				self:updateShopGV() 
			end
			NetManager.sendCmd("loadbuylist",loaddiamondshop,Constants.SHOP_TYPE.DIAMOND_SHOP)
			changeTgv(3)
			nowtgv = 3
		else
			local msg = "您未达到开启等级，请尽快升级vip等级！"
        	TipManager.showTip(msg)
        	changeTgv(nowtgv)
		end
	end)
	
	self:updateShopGV()
	
    local function event_refurbish( p_sender )
    	if self.listener1 then
    		self:getEventDispatcher():removeEventListener(self.listener1)
    		self.listener1 = nil
    	end
	    local listener1 = cc.EventListenerCustom:create("game_custom_event",function( )
	    	local shoptype = Shopdataproxy:getInstance():get("shop_type")
			local function refresh(result)
				local player = Player:getInstance()
				Shopdataproxy.goodsList = result["list"]
				Shopdataproxy:getInstance().refreshList[shoptype] = result["refreshtimes"]
				local menuConfig = ConfigManager.getMenushopConfig(shoptype)
				local moneyTypeTable = {"diamond","badge","fame"}
				player:set(moneyTypeTable[menuConfig.moneyType],player:get(moneyTypeTable[menuConfig.moneyType])-menuConfig.price)
				lab_player_gold_num:setString(player:get(moneyTypeTable[menuConfig.moneyType]))
				self.updateShopGV()
			end
			NetManager.sendCmd("refurbish",refresh,shoptype)
			listener1 = nil
	    end)
	    local eventDispatcher = self:getEventDispatcher()
	    self.listener1 = listener1
	    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)
		Utils.runUIScene("RefurbishPopup")
	end

	local btnRefurbish = layoutBottom:getChildByTag(Tag_ui_shop.BTN_REFURBISH)
	btnRefurbish:setOnClickScriptHandler(event_refurbish)
	
	local function event_return(p_sender)
		if self.listenerDiamond then
			self:getEventDispatcher():removeEventListener(self.listenerDiamond)
		end
		if self.listenerGold then
			self:getEventDispatcher():removeEventListener(self.listenerGold)
		end
		if shoptype == Constants.SHOP_TYPE.BADGE_SHOP then
			Utils.replaceScene("ExploreUI",self)
		elseif shoptype == Constants.SHOP_TYPE.PRESTIGE_SHOP then
			Utils.replaceScene("DungeonUI",self)
		else
			Utils.replaceScene("MainUI")
		end
	end
	local btnReture = layoutBottom:getChildByTag(Tag_ui_shop.BTN_RETURN)
	btnReture:setOnClickScriptHandler(event_return)

	TouchEffect.addTouchEffect(self)
end

