require "view/tagMap/Tag_ui_activity"

ActivityUI = class("ActivityUI",function()
	return TuiBase:create()
end)

ActivityUI.__index = ActivityUI
local __instance = nil

function ActivityUI:create()
	local ret = ActivityUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_activity.PANEL_ACTIVITY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close( p_sender )

	Utils.replaceScene("MainUI",__instance)
end 

function ActivityUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_activity",PATH_UI_ACTIVITY)
	local layoutBottom = self:getControl(Tag_ui_activity.PANEL_ACTIVITY,Tag_ui_activity.LAYOUT_BOTTOM)
	Utils.floatToBottom(layoutBottom)
	local btn_close = layoutBottom:getChildByTag(Tag_ui_activity.BTN_CLOSE)
	btn_close:setOnClickScriptHandler(event_close)

	local layoutTop = self:getControl(Tag_ui_activity.PANEL_ACTIVITY,Tag_ui_activity.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)

	local ImageTable = {'dailysign','supersign','recover'}
	local list = layoutTop:getChildByTag(Tag_ui_activity.LIST_ACTIVITY)
	for i=1,3 do
		local node = list:getNodeAtIndex(i-1)
		local btn_dailysign = node:getChildByTag(Tag_ui_activity.BTN_DAILYSIGN)
		btn_dailysign:setOnClickScriptHandler(function() 
			NormalDataProxy:getInstance():set("signType",i)
			if i<=2 then
				Utils.runUIScene("SignPopup")
			end
			if i == 3 then
				Utils.runUIScene("RecoverEnergyPopup")
			end
			
		end)
		btn_dailysign:setNormalSpriteFrameName('ui_activity/btn_' .. ImageTable[i] .. '_normal.png')
		btn_dailysign:setSelectedSpriteFrameName('ui_activity/btn_' .. ImageTable[i] .. '_select.png')
		if i == 1 then
			PromtManager.addRedSpot(btn_dailysign,5,"DAILY_SIGN") --添加红点监听
		elseif i ==2 then
			PromtManager.addRedSpot(btn_dailysign,5,"SUPER_SIGN") --添加红点监听
		elseif i == 3 then
			PromtManager.addRedSpot(btn_dailysign,5,"RECOVER_ENERGY") --添加红点监听
		end
	end
	TouchEffect.addTouchEffect(self)
end



