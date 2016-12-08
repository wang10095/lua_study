--
-- Author: hapigames
-- Date: 2014-11-26 12:21:57
--
require "view/tagMap/Tag_popup_pvp_buy"

PvpBuyPopup = class("PvpBuyPopup",function()
	return Popup:create()
end)

PvpBuyPopup.__index = PvpBuyPopup
local __instance = nil

function PvpBuyPopup:create()
	local ret = PvpBuyPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PvpBuyPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PvpBuyPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pvp_buy.PANEL_PVP_BUY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function buy_pvp_challenge_times()
	if Player:getInstance():get("diamond")<100 then
		Utils.popUIScene(__instance)
		Utils.useRechargeDiamond()
	else
		local buyLimit = ConfigManager.getVipConfig(Player:getInstance():get("vip")).buy_pvp_num
		if Player:getInstance():get("buyPvp1Times")>= buyLimit then
			if Player:getInstance():get("vip")>=15 then
				TipManager.showTip("今日购买次数已用完")
			else
				Utils.popUIScene(__instance)
				Utils.useRechargeDiamond("VIP等级不足","是否升级VIP以获得更多购买次数？")
			end
			return
		end
		NetManager.sendCmd("buypvp1times",function(result)
			Player:getInstance():set("buytimes",result["buytimes"])
			Player:getInstance():set("diamond",result["diamond"])
			-- TipManager.showTip("购买成功")
			SilverChampionShipproxy:getInstance():set("remaintime",1)
			if SilverChampionShipproxy:getInstance().confirmHandler  then
				SilverChampionShipproxy:getInstance().confirmHandler()
			end
			Utils.popUIScene(__instance)
		end)
	end
end

function PvpBuyPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_pvp_buy",PATH_POPUP_PVP_BUY)
	local function event_close( p_sender )
		Utils.popUIScene(self)
	end
	local btnClose = self:getControl(Tag_popup_pvp_buy.PANEL_PVP_BUY,Tag_popup_pvp_buy.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)
	local btn_sure = self:getControl(Tag_popup_pvp_buy.PANEL_PVP_BUY,Tag_popup_pvp_buy.BTN_SURE)
	btn_sure:setOnClickScriptHandler(buy_pvp_challenge_times)

	local lab_cost_num = self:getControl(Tag_popup_pvp_buy.PANEL_PVP_BUY,Tag_popup_pvp_buy.LAB_COST_NUM)
	local costbuytimes = ConfigManager.getPvp1CommonConfig('buytimescost')
	local cost = 0
	if Player:getInstance():get("buyPvp1Times")>= #costbuytimes then
		cost = costbuytimes[#costbuytimes]
	else
		cost = costbuytimes[Player:getInstance():get("buyPvp1Times")+1]
	end
	lab_cost_num:setString(cost)
	local lab_tip = self:getControl(Tag_popup_pvp_buy.PANEL_PVP_BUY,Tag_popup_pvp_buy.LAB_TIP)
	local tip = "今日挑战次数已用完\n是否花费"
	tip = tip .. "               购买1次?\n今日已购买" .. Player:getInstance():get("buyPvp1Times") .. "次"
	lab_tip:setString(tip)

	TouchEffect.addTouchEffect(self)
end








