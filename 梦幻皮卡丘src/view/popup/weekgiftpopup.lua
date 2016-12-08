--
-- Author: hapigames
-- Date: 2014-12-15 19:51:15
--
require "view/tagMap/Tag_popup_weekgift"

WeekgiftPopup = class("WeekgiftPopup",function()
	return Popup:create()
end)

WeekgiftPopup.__index = WeekgiftPopup
local __instance = nil

function WeekgiftPopup:create()
	local ret = WeekgiftPopup.new()
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function WeekgiftPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function WeekgiftPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_weekgift.PANEL_POPUP_WEEKGIFT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function WeekgiftPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_weekgift",PATH_POPUP_WEEKGIFT)
	-- local bg = self:getControl(Tag_popup_weekgift.PANEL_POPUP_WEEKGIFT, Tag_popup_weekgift.IMG9_POPUP_BG)
	-- self:setCloseTouchNode(bg)
	local function event_draw(p_sender)
		Utils.popUIScene(self)
		Utils.runUIScene("PetchosePopup")
	end
	local btn_draw = self:getControl(Tag_popup_weekgift.PANEL_POPUP_WEEKGIFT,Tag_popup_weekgift.BTN_COMMON)
	btn_draw:setOnClickScriptHandler(event_draw)
	
	TouchEffect.addTouchEffect(self)
end