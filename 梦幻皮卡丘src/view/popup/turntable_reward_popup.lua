require "view/tagMap/Tag_popup_activity1_reward"
TurntableRewardPopup = class("TurntableRewardPopup", function()
	return Popup:create()
end)

TurntableRewardPopup.__index = TurntableRewardPopup
local __instance = nil

function TurntableRewardPopup:create()
	local ret = TurntableRewardPopup.new()
	__instance = ret
	if ItemManager.currentPet ~= nil then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function TurntableRewardPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TurntableRewardPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_popup_activity1_reward.PANEL_TURNTABLE_REWARD then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end

function TurntableRewardPopup:onLoadScene()
	local score = Activity1StatusProxy:getInstance():get("score")
	TuiManager:getInstance():parseScene(self,"panel_turntable_reward",PATH_POPUP_ACTIVITY1_REWARD)
	local btn_turn_close = self:getControl(Tag_popup_activity1_reward.PANEL_TURNTABLE_REWARD,Tag_popup_activity1_reward.BTN_TURN_CLOSE)
	btn_turn_close:setOnClickScriptHandler(function() 
		Utils.popUIScene(self)
		local eventDispatcher = __instance:getEventDispatcher()
		local event = cc.EventCustom:new("game_custom_event3")
		eventDispatcher:dispatchEvent(event)
	end)

	local lab_turn_score = self:getControl(Tag_popup_activity1_reward.PANEL_TURNTABLE_REWARD,Tag_popup_activity1_reward.LAB_TURN_SCORE)
	lab_turn_score:setString(score)

	local sand = Activity1StatusProxy:getInstance():get("ernie_id")
	
	local ernieReward = ConfigManager.getActivity1ErnieReward(sand).item
	
	local layout_turn_item = self:getControl(Tag_popup_activity1_reward.PANEL_TURNTABLE_REWARD,Tag_popup_activity1_reward.LAYOUT_TURN_ITEM)
	local item = ItemManager.createItem(ernieReward[1],ernieReward[2])
	local cell = ItemCell:create(ernieReward[1],item)
	Utils.addCellToParent(cell,layout_turn_item,true)
	local lab_turn_item_num = self:getControl(Tag_popup_activity1_reward.PANEL_TURNTABLE_REWARD,Tag_popup_activity1_reward.LAB_TURN_ITEM_NUM)
	lab_turn_item_num:setString(ernieReward[3])


	TouchEffect.addTouchEffect(self)
end












