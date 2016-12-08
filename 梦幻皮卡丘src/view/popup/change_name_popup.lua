require "view/tagMap/Tag_popup_change_name"

ChangeNamePopup = class("ChangeNamePopup",function()
	return Popup:create()
end)

ChangeNamePopup.__index = ChangeNamePopup
local __instance = nil
local list  = nil
local editWord = nil

function ChangeNamePopup:create()
	local ret = ChangeNamePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChangeNamePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChangeNamePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_change_name.PANEL_POPUP_CHANGE_NAME then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_callback_change_name(result)
	local name = editWord:getText()
	Player:getInstance():set("nickname",name)
	local customEvent = cc.EventCustom:new("event_change_name")
	customEvent._usedata = name
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
	Utils.popUIScene(__instance)
end

local function event_edit_login(strEventName,pSender)
	print(strEventName)
	if strEventName == "began" or strEventName == "changed" then
		print(pSender:getText())
	elseif strEventName == "return" then
		-- local customEvent = cc.EventCustom:new("event_change_name")
		-- customEvent._usedata = pSender:getText()
		-- cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		-- Utils.popUIScene(__instance)
		-- local btnTrue = __instance:getControl(Tag_popup_change_name.PANEL_POPUP_CHANGE_NAME,Tag_popup_change_name.BTN_TRUE)
		-- btnTrue:setOnClickScriptHandler(function( )
		-- 	Utils.popUIScene(__instance)
		-- end)
	end
end

function ChangeNamePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_change_name",PATH_POPUP_CHANGE_NAME)
	local btnCancel = self:getControl(Tag_popup_change_name.PANEL_POPUP_CHANGE_NAME,Tag_popup_change_name.BTN_CANCEL)
	btnCancel:setOnClickScriptHandler(function ( )
		Utils.popUIScene(self)
	end)

	local name = PlayerProxy:getInstance():get("randomName")
	editWord = self:getControl(Tag_popup_change_name.PANEL_POPUP_CHANGE_NAME,Tag_popup_change_name.EDIT_WORD)
	editWord:setColor(cc.c3b(255,200,200))
	editWord:setText(name)
	editWord:registerScriptEditBoxHandler(event_edit_login)

	local btnTrue = __instance:getControl(Tag_popup_change_name.PANEL_POPUP_CHANGE_NAME,Tag_popup_change_name.BTN_TRUE)
	btnTrue:setOnClickScriptHandler(function()
		local playerName = editWord:getText()
		NetManager.sendCmd("changename",event_callback_change_name,editWord:getText())
	end)
	TouchEffect.addTouchEffect(self)
	-- Utils.dispatchCustomEvent("event_enter_view",{view = "MainUI",phase = GuideManager.MAIN_GUIDE_PHASES.SET_NICKNAME,scene = self})
end



