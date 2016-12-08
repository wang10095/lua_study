require "view/tagMap/Tag_popup_normal"

NormalPopup = class("NormalPopup",function()
	return Popup:create()
end)

NormalPopup.__index = NormalPopup
local __instance = nil

function NormalPopup:create()
	local ret = NormalPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function NormalPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function NormalPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_normal.PANEL_POPUP_NORMAL then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function NormalPopup:setConfirmNormalHandler(handlerP)
	self.confirmHandler = handlerP
end

function NormalPopup:setCancelNormalHandler(handlerP)
	self.cancelHandler = handlerP
end

function NormalPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_normal",PATH_POPUP_NORMAL)
	local btnConfirm = self:getControl(Tag_popup_normal.PANEL_POPUP_NORMAL, Tag_popup_normal.BTN_CONFIRM)
	local btnCancel = self:getControl(Tag_popup_normal.PANEL_POPUP_NORMAL, Tag_popup_normal.BTN_CANCEL)
	local function event_confirm(p_sender)
		Utils.popUIScene(self, self.confirmHandler)	
		NormalDataProxy:getInstance().confirmHandler = nil
	end
	btnConfirm:setOnClickScriptHandler(event_confirm)
	local function event_cancel(p_sender)
		Utils.popUIScene(self, self.cancelHandler)	
		NormalDataProxy:getInstance().cancelHandler = nil
	end
	btnCancel:setOnClickScriptHandler(event_cancel)

	local proxy = NormalDataProxy:getInstance()
	self.cancelHandler = proxy.cancelHandler                                           
	self.confirmHandler = proxy.confirmHandler
	local labTitle = self:getControl(Tag_popup_normal.PANEL_POPUP_NORMAL, Tag_popup_normal.LAB_TITLE)
	labTitle:setString(proxy:get("title"))
	local labContent = self:getControl(Tag_popup_normal.PANEL_POPUP_NORMAL, Tag_popup_normal.LAB_CONTENT)
	-- labContent:setColor(proxy:get("color"))
	-- labContent:setDimensions(proxy:get("width"), 0)
	labContent:setString(proxy:get("content"))

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
end 

