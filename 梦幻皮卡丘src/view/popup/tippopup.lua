require "view/tagMap/Tag_popup_tip"

TipPopup = class("TipPopup",function()
	return CLayout:create()
end)

TipPopup.__index = TipPopup
local __instance = nil

function TipPopup:create()
	local proxy = NormalDataProxy:getInstance()
	if proxy:get("isScene") == false then
		local ret = TipPopup.new()
		__instance = ret
		__instance:init()
		proxy:set("isScene",true)
		return ret
	else
		return nil
	end
end

function TipPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TipPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_tip.PANEL_POPUP_TIP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function TipPopup:setConfirmNormalHandler(handlerP)
	self.confirmHandler = handlerP
end

function TipPopup:setCancelNormalHandler(handlerP)
	self.cancelHandler = handlerP
end

function TipPopup:init()
	TuiManager:getInstance():parseScene(self,"panel_popup_tip",PATH_POPUP_TIP)
	
	local labContent = self:getControl(Tag_popup_tip.PANEL_POPUP_TIP, Tag_popup_tip.LAB_CONTENT)
	local proxy = TipDataProxy:getInstance()
	labContent:setString(proxy:get("content"))
	if TipDataProxy:getInstance():get("normal_or_warn")==0 then
		labContent:setColor(cc.c3b(152,255,31))  --正常提示的颜色
	else
		labContent:setColor(cc.c3b(255,255,255)) --警告提示的颜色
	end

	local delayTime  = cc.DelayTime:create(0.5)
	local fadeOut = cc.FadeOut:create(1.0)
	local sequenceLab = cc.Sequence:create(delayTime,fadeOut,nil) 
	labContent:runAction(sequenceLab)

	local bg = self:getControl(Tag_popup_tip.PANEL_POPUP_TIP, Tag_popup_tip.IMG_TIP_POPUP_BG)
	local sequenceBG = sequenceLab:clone()
	bg:runAction(sequenceBG)	

	local sequence = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
	 	__instance:removeFromParent()
	end),nil)
	self:runAction(sequence)

	local function onNodeEvent(event)
		if "enter" == event then
			-- self:show()
			
		end
		
		if "exit" == event then
			NormalDataProxy:getInstance():set("isScene",false)
			TipDataProxy:getInstance():set("normal_or_warn",0)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end 

