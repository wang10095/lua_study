--
-- Author: hapigames
-- Date: 2014-12-15 16:26:22
--
require "view/tagMap/Tag_popup_goldhand_ensure"

SecondensurePopup = class("SecondensurePopup", function()
	return Popup:create()
end)

SecondensurePopup.__index = SecondensurePopup
local __instance = nil

function SecondensurePopup:create()
	local ret = SecondensurePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SecondensurePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SecondensurePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_goldhand_ensure.PANEL_ENSURE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function SecondensurePopup:setConfirmNormalHandler(handlerP)
	self.confirmHandler = handlerP
end

function SecondensurePopup:setCancelNormalHandler(handlerP)
	self.cancelHandler = handlerP
end

function SecondensurePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_ensure",PATH_POPUP_GOLDHAND_ENSURE)
	local function event_edit(p_sender)
		Utils.popUIScene(self)
	end
	if GoldhandDataProxy:getInstance():get("isborrow") == 1 or GoldhandDataProxy:getInstance():get("isborrow") == 2 then
		local labTitle = self:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.LAB_ENSURE_1)
		labTitle:setString("副本捕捉：")
		local labTip = self:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.LAB_ENSURE_3)
		labTip:setString("次捕捉")
	end

	local proxy = NormalDataProxy:getInstance()
	self.cancelHandler = proxy.cancelHandler                                           
	self.confirmHandler = proxy.confirmHandler

	local usediamondnum = GoldhandDataProxy:getInstance():get("usediamondnum")
	local goldhandtimes =GoldhandDataProxy:getInstance():get("goldhandtimes")
	local function event_ensure(p_sender)
		if GoldhandDataProxy:getInstance():get("isborrow") == 1 then
			
			local customEvent = cc.EventCustom:new("capture_second_ensure")
  			cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

		elseif GoldhandDataProxy:getInstance():get("isborrow") == 2 then

			local customEvent = cc.EventCustom:new("sweep_capture_second_ensure")
  			cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		else
			if Player:getInstance():get("diamond")<usediamondnum then
				Utils.useRechargeDiamond()
			else
				local proxy = NormalDataProxy:getInstance()
		        if self.confirmHandler ~= nil then
					self.confirmHandler()
				end
				NormalDataProxy:getInstance().confirmHandler = nil
			end
		end
		Utils.popUIScene(self)
	end
	local btn_edit = self:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.BTN_EDIT)
	local btn_ensure = self:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.BTN_ENSURE)
	btn_edit:setOnClickScriptHandler(event_edit)
	btn_ensure:setOnClickScriptHandler(event_ensure)
	
	-- local function event_secondensure(result)
		local lab_ensure_diamondnum = __instance:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.LAB_ENSURE_DIAMONDNUM)
		local lab_goldhand_times  = __instance:getControl(Tag_popup_goldhand_ensure.PANEL_ENSURE,Tag_popup_goldhand_ensure.LAB_ENSURE_TIMES)
		lab_ensure_diamondnum:setString(usediamondnum)
		lab_goldhand_times:setString(goldhandtimes)
	-- end
	
	TouchEffect.addTouchEffect(self)
end