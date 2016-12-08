--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_capturepet"

CapturePetPopup = class("CapturePetPopup",function()
	return Popup:create()
end)

CapturePetPopup.__index = CapturePetPopup
local __instance = nil
local isSpine = false
local ballType = 0

function CapturePetPopup:create()
	local ret = CapturePetPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function CapturePetPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function CapturePetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function CapturePetPopup:dtor()
	self:getEventDispatcher():removeEventListener(self.listener)
end
local function event_exit()
	-- if NormalDataProxy:getInstance().confirmHandler then
	-- 	NormalDataProxy:getInstance().confirmHandler()
	-- end
	-- NormalDataProxy:getInstance().confirmHandler = nil
	if StageRecord:getInstance():get("sweeptimes") == 1 then
		Utils.runUIScene("SweepOncePopup")
	else
		Utils.runUIScene("SweepPopup")
	end
	Utils.popUIScene(__instance)
end

local function event_close( p_sender )
	local pettable =  Stagedataproxy.StageList
	local captureNum = Stagedataproxy:getInstance():get("CapturePetNum") --去扑捉的第几个宠物
	if captureNum < #pettable then
		Stagedataproxy:getInstance():set("CapturePetNum",Stagedataproxy:getInstance():get("CapturePetNum")+1)
		__instance:updateUI()
	else
		local delay = cc.DelayTime:create(2.0)
		local callfunc = cc.CallFunc:create(event_exit)
		__instance:runAction(cc.Sequence:create(delay,callfunc,nil))
	end
end

function CapturePetPopup:updateUI()
	local pettable =  Stagedataproxy.StageList
	-- local petTable = {{'15299_3',33,1,0,1,1,3,0,{1,1},1,0,6,{8075,2691}}}
	local captureNum = Stagedataproxy:getInstance():get("CapturePetNum") --去扑捉的第几个宠物

	local normalnum = ItemManager.getItemAmount(2,1)
	local supernum = ItemManager.getItemAmount(2,2)

	local getPetModel = ConfigManager.getPetFormConfig(pettable[captureNum]["mid"],pettable[captureNum]["form"])
	local layoutPet = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_PET)--大图显示
	layoutPet:removeAllChildren()
	local img = TextureManager.createImg("portrait/".. getPetModel.model ..".png")
	Utils.addCellToParent(img,layoutPet,true)
	img:setScale(0.01)
	img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1.0),nil))

	local petName = TextManager.getPetName(pettable[captureNum]["mid"],pettable[captureNum]["form"])
	local petAptitude = TextManager.getPetAptitudeName(pettable[captureNum]["aptitude"])
	local petCharacter = TextManager.getPetCharacterName(pettable[captureNum]["character"])
	layoutBottom = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_BOTTOM)
	local labPetName = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_NAME)
	local labPetAptitude = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_APTITUDE)
	local labPetCharacter = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_CHARACTER)
	local labPetGrowths1 = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_TIPS_2)
	local labPetGrowth = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_BASE1)
	local labPetGrowths2 = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_TIPS_ATTACK)
	local labPetGrowths3 = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_BASE3)
	
	labPetName:setString(petName)
	labPetAptitude:setString(petAptitude)
	labPetCharacter:setString(petCharacter)
	labPetName:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetAptitude:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetCharacter:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetGrowths1:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetGrowths2:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetGrowth:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	labPetGrowths3:setColor(Constants.APTITUDE_COLOR[pettable[captureNum]["aptitude"]])
	
	local layoutNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.LAYOUT_NORMAL_CAPTURE)
	local layoutSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.LAYOUT_SUPER_CAPTURE)
	local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
	local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)

	local function onCapturePetHandler( result )
		isSpine = true
		local atlas = TextureManager.RES_PATH.CAPTURE..".atlas"
		local json = TextureManager.RES_PATH.CAPTURE..".json"
		local spine = sp.SkeletonAnimation:create(json, atlas,1)
		local layoutSpine = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_SPINE)
		layoutSpine:removeAllChildren()
		spine:setPosition(cc.p(layoutSpine:getContentSize().width/2,layoutSpine:getContentSize().height/2))
		layoutSpine:addChild(spine,1)
		Player:getInstance():set("diamond",result["diamond"])
		ItemManager.updateItem(Constants.ITEM_TYPE.MATERIAL, result["ball_type"], result["ball_num"])
		if result["ball_type"] == 1 then
			labNormalAmount:setString(result["ball_num"])
		else
			labSuperAmount:setString(result["ball_num"])
		end
		layoutPet:setVisible(false)

		if result["flag"] == 0 then
			-- TipManager.showTip("捕捉失败")
			MusicManager.subMusicVolume(1)
			MusicManager.capture_fail()
			spine:setAnimation(0, "normal_fail", false)
		else
			local pid = result["pid"] -- 新的宠物id
			local newpet = {} --新的宠物
			for k,v in pairs(pettable[captureNum]) do
				if k == 'id' then
					newpet[k] = pid
				else
					newpet[k] = v
				end
			end
			ItemManager.addPet(newpet)
			-- TipManager.showTip("捕捉成功")
			MusicManager.subMusicVolume(1)
			MusicManager.capture_succ()
			if ballType == 1 then
				spine:setAnimation(0, "normal_success", false)
			else
				spine:setAnimation(0, "super_success", false)
			end
		end

		if captureNum < #pettable then
			Stagedataproxy:getInstance():set("CapturePetNum",Stagedataproxy:getInstance():get("CapturePetNum")+1)
			captureNum = captureNum + 1
			__instance:runAction(cc.Sequence:create(cc.DelayTime:create(7.0),cc.CallFunc:create(function()

				__instance:updateUI()
				TipManager.showTip(string.format("可捕捉的宠物还有 %d 只哦～",#pettable - (captureNum-1)))
				local getPetModel = ConfigManager.getPetFormConfig(pettable[captureNum]["mid"],pettable[captureNum]["form"])
				layoutPet:setVisible(true)
				layoutPet:removeAllChildren()
				spine:removeFromParent()
				local img = TextureManager.createImg("portrait/".. getPetModel.model ..".png")
				Utils.addCellToParent(img,layoutPet,true)
				img:setScale(0.01)
				img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1.0),nil))
				MusicManager.addMusicVolume(1)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				local btn_close = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
				btn_close:setEnabled(true)
				btnSuper:setEnabled(true)
				btnNormal:setEnabled(true)
				isSpine = false
			end)))
		else
			__instance:runAction(cc.Sequence:create(cc.DelayTime:create(7.0),cc.CallFunc:create(function( )
				MusicManager.addMusicVolume(1)
				local btn_close = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
				btn_close:setEnabled(true)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				btnSuper:setEnabled(true)
				btnNormal:setEnabled(true)
				isSpine = false
			end)))
			
			local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			local newPet = true
			for i,pet in pairs(petContent) do
				if pet:get("mid") == pettable[captureNum]["mid"] then
					newPet = false
				end
			end
			if newPet and result["flag"] == 1 then
				local delay = cc.DelayTime:create(7.0)
				local callfunc2 = cc.CallFunc:create(function( )
					GuideManager.guide_pet = 0
					WildDataProxy:getInstance():set("newPet_mid",pettable[captureNum]["mid"])
					WildDataProxy:getInstance():set("newPet_form",pettable[captureNum]["form"])
					if NormalDataProxy:getInstance().confirmHandler then
						NormalDataProxy:getInstance().confirmHandler = nil
					end
					NormalDataProxy:getInstance().confirmHandler = function( )
						event_exit()
					end
					Utils.runUIScene("NewPetPopup")
				end)
				__instance:runAction(cc.Sequence:create(delay,callfunc2,cc.CallFunc:create(function( )
					isSpine = false
				end)))
				
			else
				local delay = cc.DelayTime:create(7.0)
				local callfunc = cc.CallFunc:create(event_exit)
				__instance:runAction(cc.Sequence:create(delay,callfunc,cc.CallFunc:create(function( )
					isSpine = false
				end)))
			end
		end
	end

	local function event_capture_superball( p_sender )
		if isSpine == true then
			return
		end
		if supernum <= 0 then
			if Player:getInstance():get("diamond") < 100 then
				TipManager.showTip("当前钻石不足")
				return
			end
			ballType = 2
			if __instance.listener then
				__instance:getEventDispatcher():removeEventListener(__instance.listener)
    			__instance.listener = nil
			end
			local diamondCapture = ConfigManager.getStageCommonConfig('advanced_diamond')
			GoldhandDataProxy:getInstance():set("usediamondnum",diamondCapture)
			GoldhandDataProxy:getInstance():set("goldhandtimes",1)
			GoldhandDataProxy:getInstance():set("isborrow",2)
			Utils.runUIScene("SecondensurePopup")
			local listener = cc.EventListenerCustom:create("sweep_capture_second_ensure", function( )
				NetManager.sendCmd("sweeprewardpet",onCapturePetHandler,pettable[captureNum]["id"],2)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				btnSuper:setEnabled(false)
				btnNormal:setEnabled(false)
				GoldhandDataProxy:getInstance():set("isborrow",0)
				listener = nil
			end)
			__instance.listener = listener
			local dispatcher = cc.Director:getInstance():getEventDispatcher()
			dispatcher:addEventListenerWithFixedPriority(listener, 1)
		else
			ballType = 2
			local btn_close = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
			btn_close:setEnabled(false)
			local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
			local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
			btnSuper:setEnabled(false)
			btnNormal:setEnabled(false)
			NetManager.sendCmd("sweeprewardpet",onCapturePetHandler,pettable[captureNum]["id"],2)
		end
	end
	
	local function event_capture_normalball( p_sender )
		if isSpine == true then
			return
		end
		if normalnum <= 0 then
			if Player:getInstance():get("diamond") < 100 then
				TipManager.showTip("当前钻石不足")
				return
			end
			ballType = 1
			if __instance.listener then
				__instance:getEventDispatcher():removeEventListener(__instance.listener)
    			__instance.listener = nil
			end
			local diamondCapture = ConfigManager.getStageCommonConfig('advanced_diamond')
			GoldhandDataProxy:getInstance():set("usediamondnum",diamondCapture)
			GoldhandDataProxy:getInstance():set("goldhandtimes",1)
			GoldhandDataProxy:getInstance():set("isborrow",2)
			Utils.runUIScene("SecondensurePopup")
			local listener = cc.EventListenerCustom:create("sweep_capture_second_ensure", function( )
				NetManager.sendCmd("sweeprewardpet",onCapturePetHandler,pettable[captureNum]["id"],1)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				btnSuper:setEnabled(false)
				btnNormal:setEnabled(false)
				GoldhandDataProxy:getInstance():set("isborrow",0)
				listener = nil
			end)
			__instance.listener = listener
			local dispatcher = cc.Director:getInstance():getEventDispatcher()
			dispatcher:addEventListenerWithFixedPriority(listener, 1)
		else
			ballType = 1
			local btn_close = __instance:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
			btn_close:setEnabled(false)
			local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
			local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)

			btnNormal:setEnabled(false)
			btnSuper:setEnabled(false)
			NetManager.sendCmd("sweeprewardpet",onCapturePetHandler,pettable[captureNum]["id"],1)
		end
	end

	btnNormal:setOnClickScriptHandler(event_capture_normalball)
	btnSuper:setOnClickScriptHandler(event_capture_superball)


	labSuperAmount = layoutSuper:getChildByTag(Tag_popup_capturepet.LAB_SUPERBALL_AMOUNT)
	labSuperAmount:setString(supernum)
	labNormalAmount = layoutNormal:getChildByTag(Tag_popup_capturepet.LAB_NORMALBALL_AMOUNT)
	labNormalAmount:setString(normalnum)
end

function CapturePetPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_capturepet",PATH_POPUP_CAPTUREPET)
	-- local btnGiveUp = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_RETURN)
	-- btnGiveUp:setOnClickScriptHandler(event_close)--放弃捕捉
	layoutBottom = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_BOTTOM)

	local btn_close = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
	btn_close:setOnClickScriptHandler(function()
		local delay = cc.DelayTime:create(0.3)
		local callfunc = cc.CallFunc:create(event_exit)
		self:runAction(cc.Sequence:create(delay,callfunc,nil))
	end)
	self:updateUI()
	TouchEffect.addTouchEffect(self)
end

