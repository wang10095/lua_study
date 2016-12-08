require "view/tagMap/Tag_popup_recover_energy"

RecoverEnergyPopup = class("RecoverEnergyPopup", function()
	return Popup:create()
end)

RecoverEnergyPopup.__index = RecoverEnergyPopup
local __instance = nil

function RecoverEnergyPopup:create()
	local ret = RecoverEnergyPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RecoverEnergyPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RecoverEnergyPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_recover_energy.PANEL_RECOVER_ENERGY	 then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close(pSender)
	Utils.popUIScene(__instance)
end

function RecoverEnergyPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_recover_energy",PATH_POPUP_RECOVER_ENERGY)
	local btn_recover_close = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.BTN_RECOVER_CLOSE)
	btn_recover_close:setOnClickScriptHandler(event_close)
	local layout_energy_spine = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.LAYOUT_ENERGY_SPINE)
	local imgTalkBg = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.IMG_TALK_BG)
	local labTalk = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.LAB_TALK)
	
 	labTalk:setString("")
    NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.EnergyRecover)
    NpcTalkManager.setNPCTouch(self,layout_energy_spine,labTalk,NpcTalkManager.SCENE.EnergyRecover)
    imgTalkBg:setVisible(false)
	labTalk:setVisible(false)
	
	local canEat = true
	local count = 1

	local function load_recover_energy(result)
		local status = result["status"]
		if status == 0 then
			canEat = true
			count = 1
		else
			canEat = false
			count = 4
		end
		if status == 0 then
			imgTalkBg:setVisible(true)
			labTalk:setVisible(true)
		else
			imgTalkBg:setVisible(false)
			labTalk:setVisible(false)
		end
		
		local layout_energy_spine = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.LAYOUT_ENERGY_SPINE)
		local atlas = "spine/spine_activity/spine_energy_recover.atlas"
		local json  = "spine/spine_activity/spine_energy_recover.json"
		local spine = sp.SkeletonAnimation:create(json, atlas)
		spine:setAnimation(0, "part" .. count, true)
		Utils.addCellToParent(spine,layout_energy_spine)

		local layout_eat = self:getControl(Tag_popup_recover_energy.PANEL_RECOVER_ENERGY,Tag_popup_recover_energy.LAYOUT_EAT)
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(function(touch,event)
			local location = layout_eat:convertTouchToNodeSpace(touch)
			local size = layout_eat:getContentSize()
			if size and canEat == true and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
				spine:setAnimation(0, "part2", true)
				return true
			end
		end,cc.Handler.EVENT_TOUCH_BEGAN )   
		listener:registerScriptHandler(function(touch,event)
			local function callback_recover_energy(result)
				TipManager.showTip("恢复体力成功 当前体力" .. result["energy"])
				Player:getInstance():set("energy",result["energy"])
				spine:setAnimation(0, "part3", false) --成功后播放吃面动画 
				canEat = false
				PromtManager.NewsTable.RECOVER_ENERGY.status = false
			 	PromtManager.checkOnePromt("RECOVER_ENERGY")
			 	imgTalkBg:setVisible(false)
				labTalk:setVisible(false)
			end
			NetManager.sendCmd("recoveryenergy",callback_recover_energy)
		end,cc.Handler.EVENT_TOUCH_ENDED )  
		local eventDispatcher = layout_eat:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layout_eat)
	end
	NetManager.sendCmd("loadrecoverenergy", load_recover_energy)

	TouchEffect.addTouchEffect(self)
end






