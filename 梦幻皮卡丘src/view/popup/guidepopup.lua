require "view/tagMap/Tag_popup_guide"

GuidePopup = class("GuidePopup",function()
	return Popup:create()
end)

GuidePopup.__index = GuidePopup
local __instance = nil
function GuidePopup:create()
	local ret = GuidePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function GuidePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function GuidePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_guide.PANEL_GUIDE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function closeGuideHandler( callback,params )
	print("popUIScene")
	Utils.popUIScene(__instance)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local event = cc.EventCustom:new("exit_guide")
	eventDispatcher:dispatchEvent(event)
end

function GuidePopup:onLoadScene() 
	TuiManager:getInstance():parseScene(self,"panel_guide",PATH_POPUP_GUIDE)
	local guide = self:getControl(Tag_popup_guide.PANEL_GUIDE, Tag_popup_guide.LAYOUT_GUIDE)
	local mask = GuideManager.addMask(2,1,1)
	GuideManager.addGuideMask(mask, guide)
	
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local closePopupListener = cc.EventListenerCustom:create("close_guide", function(event)
		-- closeGuideHandler(event._usedata.callback, event._usedata.params)
		closeGuideHandler()
	end)
    eventDispatcher:addEventListenerWithFixedPriority(closePopupListener, 1)

	-- local state = GuideDataProxy:getInstance():getCurrentState()
	-- state.UI = self
end