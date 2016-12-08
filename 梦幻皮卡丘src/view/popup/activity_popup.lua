--
-- Author: hapigames
-- Date: 2014-12-12 17:15:39
--
require "view/tagMap/Tag_popup_activity"

ActivityPopup = class("ActivityPopup",function()
	return Popup:create()
end)

ActivityPopup.__index = ActivityPopup
local __instance = nil
function ActivityPopup:create()
	local ret = ActivityPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_activity.PANEL_POPUP_ACTIVITY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function ActivityPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_activity",PATH_POPUP_ACTIVITY)
	local function event_close( p_sender )
		Utils.popUIScene(self)
	end 
	local btn_close = self:getControl(Tag_popup_activity.PANEL_POPUP_ACTIVITY,Tag_popup_activity.BTN_CLOSE)
	btn_close:setOnClickScriptHandler(event_close)
	
	local list = self:getControl(Tag_popup_activity.PANEL_POPUP_ACTIVITY,Tag_popup_activity.LIST_REGISTRATION)
	for i=1,30 do
		local node = list:getNodeAtIndex(i-1)
		for j=1,3 do
			local layoutItem = node:getChildByTag(Tag_popup_activity["LAYOUT_ITEM"..i])
			local img = TextureManager.createImg(TextureManager.RES_PATH.ITEM_IMAGE,j,1)
			Utils.addCellToParent(img,layoutItem)
		end
		
	end
	list:reloadData()
	TouchEffect.addTouchEffect(self)
end