--
-- Author: hapigames
-- Date: 2014-11-26 16:58:09
--

require "view/tagMap/Tag_poupup_shop_refurbish"

RefurbishPopup = class("RefurbishPopup",function()
	return Popup:create()
end)

RefurbishPopup.__index = RefurbishPopup
local __instance = nil
function RefurbishPopup:create()
	local ret = RefurbishPopup.new()
	__instance = ret
	
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RefurbishPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RefurbishPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_poupup_shop_refurbish.PANEL_REFURBISH then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function RefurbishPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_refurbish",PATH_POUPUP_SHOP_REFURBISH)
	local shoptype = Shopdataproxy:getInstance():get("shop_type")
	local labTimes = self:getControl(Tag_poupup_shop_refurbish.PANEL_REFURBISH,Tag_poupup_shop_refurbish.LAB_TIMES)
	labTimes:setString(Shopdataproxy:getInstance().refreshList[shoptype])
	
	local menuShopConfig = ConfigManager.getMenushopConfig(shoptype)
	local costMoneyType = {"diamond","badge","fame"}
	local alertType = {"钻石不足","徽章不足","声望不足"}
	local function event_function_ensure( p_sender )
		if Shopdataproxy:getInstance().refreshList[shoptype] >= menuShopConfig.limitNum then
			TipManager.showTip("今日刷新次数已达上限")
		else
			if Player:getInstance():get(costMoneyType[menuShopConfig.moneyType])<menuShopConfig.price then
				if menuShopConfig.moneyType==1 then
					Utils.useRechargeDiamond()
				else
					TipManager.showTip(alertType[menuShopConfig.moneyType])
				end
			else
				local eventDispatcher = __instance:getEventDispatcher()
				local event = cc.EventCustom:new("game_custom_event")
				eventDispatcher:dispatchEvent(event)
			end
		end
		Utils.popUIScene(self)
	end
	local function event_function_canacel( p_sender )
		Utils.popUIScene(self)
	end

	local btn_cancel = self:getControl(Tag_poupup_shop_refurbish.PANEL_REFURBISH,Tag_poupup_shop_refurbish.BTN_EDIT)
	local btn_ture = self:getControl(Tag_poupup_shop_refurbish.PANEL_REFURBISH,Tag_poupup_shop_refurbish.BTN_TRUE)
	btn_cancel:setOnClickScriptHandler(event_function_canacel)
	btn_ture:setOnClickScriptHandler(event_function_ensure)

	local img_diamond = self:getControl(Tag_poupup_shop_refurbish.PANEL_REFURBISH,Tag_poupup_shop_refurbish.IMG_DIAMOND)
	if shoptype < 4 then
		img_diamond:setSpriteFrame("component_common/img_diamond.png")
	elseif shoptype == Constants.SHOP_TYPE.BADGE_SHOP then
		img_diamond:setSpriteFrame("component_common/img_badge.png")
		img_diamond:setScale(0.5)
	elseif shoptype == Constants.SHOP_TYPE.PRESTIGE_SHOP then
		img_diamond:setSpriteFrame("component_common/img_prestige.png")
		img_diamond:setScale(0.5)
	end
	local lab_num = self:getControl(Tag_poupup_shop_refurbish.PANEL_REFURBISH,Tag_poupup_shop_refurbish.LAB_NUM)
	lab_num:setString(menuShopConfig.price)

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
