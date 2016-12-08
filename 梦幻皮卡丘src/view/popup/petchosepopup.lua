--
-- Author: hapigames
-- Date: 2014-12-15 19:55:06
--
require "view/tagMap/Tag_popup_weekgift"

PetchosePopup = class("PetchosePopup",function()
	return Popup:create()
end)

PetchosePopup.__index = PetchosePopup
local __instance = nil

function PetchosePopup:create()
	local ret = PetchosePopup.new()
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetchosePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetchosePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_weekgift.PANEL_POPUP_PETCHOSE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PetchosePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_petchose",PATH_POPUP_WEEKGIFT)
	
	local function event_close(p_sender )
		Utils.popUIScene(self)
	end
	local btn_close = self:getControl(Tag_popup_weekgift.PANEL_POPUP_PETCHOSE,Tag_popup_weekgift.BTN_PETCHOSE_CLOSE)
	btn_close:setOnClickScriptHandler(event_close)
	TouchEffect.addTouchEffect(self)
end
