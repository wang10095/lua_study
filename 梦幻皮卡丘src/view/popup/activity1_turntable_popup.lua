require "view/tagMap/Tag_popup_activity1_turntable"

ActivityTurnTablePopup = class("ActivityTurnTablePopup",function()
	return Popup:create()
end)

ActivityTurnTablePopup.__index = ActivityTurnTablePopup
local __instance = nil
local hasStart 

function ActivityTurnTablePopup:create()
	local ret = ActivityTurnTablePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityTurnTablePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityTurnTablePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_activity1_turntable.PANEL_POPUP_ACTIVITY1_TURNTABLE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function ActivityTurnTablePopup:onLoaddiscountevent()
	local token = Activity1StatusProxy:getInstance():get("token")
 	local function activity1ernieshop( result )
		Utils.popUIScene(__instance)
 		Activity1StatusProxy:getInstance():set("qid",result["shopinfo"])
 		Activity1StatusProxy:getInstance():set("token",result["token"])
 		Utils.runUIScene("ActivityDiscountPopup")
 	end
 	NetManager.sendCmd("activity1ernieshop",activity1ernieshop,__instance.activity1Type,token)
end 

local function onloadtips()
	local sand = Activity1StatusProxy:getInstance():get("ernie_id")
	local ernieReward = TextManager.getActivity1ErnieReward(sand).item
	local player = Player:getInstance()
	local score = Activity1StatusProxy:getInstance():get("score")
	if sand == 1 then
		player:set("gold",player:get("gold")+ernieReward)
		TipManager.showTip("获得金币 +" .. ernieReward .. " 当前得分 " ..score)
		local eventDispatcher = __instance:getEventDispatcher()
		local event = cc.EventCustom:new("game_custom_event3")
		eventDispatcher:dispatchEvent(event)
	elseif sand == 2 then
		player:set("gold",player:get("diamond")+ernieReward)
		TipManager.showTip("获得钻石 +" .. ernieReward .. " 当前得分 " .. score)
		local eventDispatcher = __instance:getEventDispatcher()
		local event = cc.EventCustom:new("game_custom_event3")
		eventDispatcher:dispatchEvent(event)
	elseif sand == 3 then
		Utils.runUIScene("TurntableRewardPopup")
	elseif sand == 4 then
		Utils.runUIScene("TurntableRewardPopup")
	end
	Utils.popUIScene(__instance)
end

function ActivityTurnTablePopup:onLoadScene()
	hasStart = false 
	TuiManager:getInstance():parseScene(self,"panel_popup_activity1_turntable",PATH_POPUP_ACTIVITY1_TURNTABLE)
	sand = Activity1StatusProxy:getInstance():get("ernie_id") -- 获得四号事件
	ernieConfig = ConfigManager.getActivity1CouponConfig(sand)
	self.activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
	local layoutTurnTable = self:getControl(Tag_popup_activity1_turntable.PANEL_POPUP_ACTIVITY1_TURNTABLE,Tag_popup_activity1_turntable.LAYOUT_TURNTABLE)
		
	local function event_turn( p_sender )
		MusicManager.turntable()
		if hasStart == true then
			return
		end
		hasStart = true
    	if sand == 1 then   --金币
			local seq = cc.Sequence:create(
	        cc.RotateTo:create(2, 360+360*sand),
	        cc.RotateTo:create(1, 0),
	        cc.DelayTime:create(0.5),
	        cc.CallFunc:create(onloadtips))
			layoutTurnTable:runAction(seq)
		elseif sand == 2 then  --钻石
			local seq = cc.Sequence:create(
	        cc.RotateTo:create(2, 360+360*sand+180),
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(onloadtips))
			layoutTurnTable:runAction(seq)
		elseif sand == 3 then --超级球
			local seq = cc.Sequence:create(
	        cc.RotateTo:create(2, 360+360*sand+230),
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(onloadtips))
			layoutTurnTable:runAction(seq)
		elseif sand == 4 then --神奇宝贝经验道具
			local seq = cc.Sequence:create(
	        cc.RotateTo:create(2, 360+360*sand+90),
	        cc.DelayTime:create(1),
	        cc.CallFunc:create(onloadtips))
			layoutTurnTable:runAction(seq)
		elseif sand == 5 then --半价优惠
			local seq = cc.Sequence:create(
	        cc.RotateTo:create(2, 360+360*sand+230),
	        cc.DelayTime:create(0.5),
	        cc.CallFunc:create(__instance.onLoaddiscountevent))
			layoutTurnTable:runAction(seq)
		end
		
	end
	local btnStart = self:getControl(Tag_popup_activity1_turntable.PANEL_POPUP_ACTIVITY1_TURNTABLE,Tag_popup_activity1_turntable.BTN_START)
	btnStart:setOnClickScriptHandler(event_turn)
	TouchEffect.addTouchEffect(self)
end