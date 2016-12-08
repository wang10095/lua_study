require "view/tagMap/Tag_popup_selectservicer"

ServicerPopup = class("ServicerPopup", function()
	return Popup:create()
end)

ServicerPopup.__index = ServicerPopup
local __instance = nil

function ServicerPopup:create()
	local ret = ServicerPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ServicerPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ServicerPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_popup_selectservicer.PANEL_POPUP_SELECTSERVICER then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function ServicerPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_selectservicer",PATH_POPUP_SELECTSERVICER)
	local list = self:getControl(Tag_popup_selectservicer.PANEL_POPUP_SELECTSERVICER,Tag_popup_selectservicer.LIST_SERVER)
	list:removeAllNodes()
	local amount = 12
  	local count = list:getNodeCount()
  	while count < amount  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell,"cell_server",PATH_POPUP_SELECTSERVICER)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()
	for i=1, amount do
		local node = list:getNodeAtIndex(i-1)
		local servicerConfig = TextManager.getServicerName(i)
		local labServicerth = node:getChildByTag(Tag_popup_selectservicer.LAB_SERVERTH)
		labServicerth:setString(i)
		local labServerName = node:getChildByTag(Tag_popup_selectservicer.LAB_SERVER_NAME)
		labServerName:setString(servicerConfig.name)
		local function event_select( p_sender )
			Utils.popUIScene(__instance)
		end
		local btnServer = node:getChildByTag(Tag_popup_selectservicer.BTN_SERVER2)
		btnServer:setOnClickScriptHandler(event_select)
	end

	local function event_select( p_sender )
		Utils.popUIScene(self)
	end
	local btnServer = self:getControl(Tag_popup_selectservicer.PANEL_POPUP_SELECTSERVICER,Tag_popup_selectservicer.BTN_SERVER1)
	btnServer:setOnClickScriptHandler(event_select)
end