require "view/tagMap/Tag_popup_pve_chest"

ChestRewardPopup = class("ChestRewardPopup",function()
	return Popup:create()
end)

ChestRewardPopup.__index = ChestRewardPopup
local __instance = nil

function ChestRewardPopup:create()
	local ret = ChestRewardPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChestRewardPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret    
end

function ChestRewardPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pve_chest.PANEL_CHEST_REWARD then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

function ChestRewardPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_chest_reward",PATH_POPUP_PVE_CHEST)
	local btnClose = self:getControl(Tag_popup_pve_chest.PANEL_CHEST_REWARD, Tag_popup_pve_chest.BTN_CHEST_CLOSE_POPUP)
	btnClose:setOnClickScriptHandler(event_close)

	local rewardConfig = ConfigManager.getPveStarReward(StageRecord:getInstance():get("dungeonType"), Stagedataproxy:getInstance():get("chapter") )   
	local lab_chest_tips = self:getControl(Tag_popup_pve_chest.PANEL_CHEST_REWARD, Tag_popup_pve_chest.LAB_CHEST_TIPS)
	local stringTip = lab_chest_tips:getString()
	stringTip = string.gsub(stringTip,'xx',tostring(rewardConfig.star))
	stringTip = string.gsub(stringTip,'yy',tostring(rewardConfig.diamond))
	lab_chest_tips:setString(stringTip)
	
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			Stagedataproxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			Stagedataproxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end 

