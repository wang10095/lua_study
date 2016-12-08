require "view/tagMap/Tag_ui_trial"

TrialRankPopup = class("TrialRankPopup",function()
	return Popup:create()
end)

TrialRankPopup.__index = TrialRankPopup
local __instance = nil

function TrialRankPopup:create()
	local ret = TrialRankPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function TrialRankPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TrialRankPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_trial.PANEL_RANK then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function TrialRankPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_rank",PATH_UI_TRIAL)

	--set touch border
	-- local bg = self:getControl(Tag_ui_trial.PANEL_RANK, Tag_ui_trial.IMG9_RANK)
	-- self:setCloseTouchNode(bg)
	TouchEffect.addTouchEffect(self)
end 

