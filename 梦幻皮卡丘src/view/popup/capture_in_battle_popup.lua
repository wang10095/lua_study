
require "view/tagMap/Tag_popup_capturepet"

CaptureInBattlePopup = class("CaptureInBattlePopup",function()
	return Popup:create()
end)

CaptureInBattlePopup.__index = CaptureInBattlePopup
local __instance = nil
local catching  = false

function CaptureInBattlePopup:create()
	local ret = CaptureInBattlePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function CaptureInBattlePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function CaptureInBattlePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function CaptureInBattlePopup:dtor( )
	self:getEventDispatcher():removeEventListener(self.listener)
end

local function event_close( p_sender )
	Utils.popUIScene(__instance)
	local event = cc.EventCustom:new("event_battle_capture")
	__instance:getEventDispatcher():dispatchEvent(event)
end

function CaptureInBattlePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_capturepet",PATH_POPUP_CAPTUREPET)
	local winSize = cc.Director:getInstance():getVisibleSize()
	local normal_ball = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL, 1)
	local super_ball = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL, 2)
	-- local imgTitle = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.IMG_CAN_GET_BG)
	-- imgTitle:setScale(0.01)
	-- imgTitle:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.4,1.2),cc.ScaleTo:create(0.2,1),cc.MoveBy:create(0.5,cc.p(0,180))))
	local ball_type
	local btnGiveUp = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.BTN_CLOSE)
	btnGiveUp:setOnClickScriptHandler(event_close)

	local pets = StageRecord:getInstance():get("pets")
	local mid 
	local form 
	local aptitude
	local character
	local pet
	if GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.CAPTURE then
		local config = ConfigManager.getGuidePetConfig(6)
		mid = config.mid
		form = 1
		aptitude = 1
		character = config.character
		pet = Pet:create()
		pet:set("mid",mid)
		pet:set("form",form)
		pet:set("aptitude",aptitude)
		pet:set("character",character)
		StageRecord:getInstance():set("pet")
	else
		pet = table.remove(pets)
		mid = pet.mid
		form = pet.form
		aptitude = pet.aptitude
		character = pet.character
	end
	print("======" .. mid,form)
	-- Debug.simplePrintTable(pet)
	local petConfig = ConfigManager.getPetFormConfig(mid,form)
	layoutPet = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_PET)--大图显示
	local img = TextureManager.createImg("portrait/".. petConfig.model ..".png")
	Utils.addCellToParent(img,layoutPet)
	layoutPet:setScale(0.75)
	
	local petName = TextManager.getPetName(mid, form)
	local petAptitude = TextManager.getPetAptitudeName(aptitude)
	local petCharacter = TextManager.getPetCharacterName(character)
	local layoutBottom = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_BOTTOM)

	local labPetName = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_NAME)
	local labPetCharacter = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_CHARACTER)
	local labPetGrowths1 = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_TIPS_2)
	local labPetGrowth = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_BASE1)
	local labPetGrowths2 = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_TIPS_ATTACK)
	local labPetGrowths3 = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_BASE3)
	local labPetAptitude = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAB_PET_APTITUDE)
	labPetName:setString(petName)
	labPetName:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetCharacter:setString(petCharacter)
	labPetCharacter:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetAptitude:setString(petAptitude)
	labPetAptitude:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetGrowths1:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetGrowths2:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetGrowth:setColor(Constants.APTITUDE_COLOR[aptitude])
	labPetGrowths3:setColor(Constants.APTITUDE_COLOR[aptitude])
	local layoutBottom = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_BOTTOM)
	-- layoutMove:runAction(cc.Sequence:create(cc.DelayTime:create(1.4),cc.MoveBy:create(0.4,cc.p(0,365))))

	-- local layoutWood = layoutMove:getChildByTag(Tag_popup_capturepet.IMG_CAPTURE_BOTTOM)
	local layoutNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.LAYOUT_NORMAL_CAPTURE)
	local layoutSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.LAYOUT_SUPER_CAPTURE)
	local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
	local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
	local layoutSpine = self:getControl(Tag_popup_capturepet.PANEL_POPUP_CAPTUREPET,Tag_popup_capturepet.LAYOUT_SPINE)
	
	local initConfig = ConfigManager.getUserinitConfig('normal_ball')
	local labNormalAmount = layoutNormal:getChildByTag(Tag_popup_capturepet.LAB_NORMALBALL_AMOUNT)
	local labSuperBallAmount = layoutSuper:getChildByTag(Tag_popup_capturepet.LAB_SUPERBALL_AMOUNT)

	labNormalAmount:setString(normal_ball)
	if GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.CAPTURE then
		labSuperBallAmount:setString(1)
	else
		labSuperBallAmount:setString(super_ball)
	end
	local function onCapture(result)
		--更新宠物
		local function runSpine()
			local atlas = TextureManager.RES_PATH.CAPTURE..".atlas"
			local json = TextureManager.RES_PATH.CAPTURE..".json"
			local spine = sp.SkeletonAnimation:create(json, atlas,1)
			catching = true
			local size = layoutSpine:getContentSize()
			if GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
				spine:setAnimation(0, "super_success", false)
				labSuperBallAmount:setString(0)
			else
				if result.flag == 1 then
					if ball_type == 1 then --普通球
						MusicManager.subMusicVolume(1)
						MusicManager.capture_succ()
						spine:setAnimation(0, "normal_success", false)
					else --超级球
						MusicManager.subMusicVolume(1)
						MusicManager.capture_succ()
						spine:setAnimation(0, "super_success", false)
					end
				else --扑捉失败 
					MusicManager.subMusicVolume(1)
					MusicManager.capture_fail()
					spine:setAnimation(0, "normal_fail", false)
				end
				if ball_type == 1 and normal_ball > 0 then --普通球
					normal_ball = normal_ball - 1
					labNormalAmount:setString(normal_ball)
				elseif ball_type == 2 and super_ball > 0 then
					super_ball = super_ball - 1
					labSuperBallAmount:setString(super_ball)
				end
			end
			spine:setPosition(cc.p(size.width/2, size.height/2))
			layoutSpine:addChild(spine)
		end 
		local function runVisbilef()
			layoutPet:setVisible(false)
			layoutPet:setScale(0.1)
		end
		local function runVisbilet( )
			layoutPet:setVisible(true)
			layoutPet:runAction(cc.ScaleTo:create(0.3,1))
		end
		local function captureDone() --捕捉完毕
			MusicManager.addMusicVolume(1)
			local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
			local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
			btnSuper:setEnabled(true)
			btnNormal:setEnabled(true)
			catching  = false
			Utils.popUIScene(__instance)
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
				ItemManager.updatePets(result["pets"])
				local function confirmHandler()
					local event = cc.EventCustom:new("event_battle_capture")
					event._usedata = {result = result, pet = pet}
					cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
					GuideManager.guide_pet = 0
				end
				GuideManager.guide_pet = 4
				WildDataProxy:getInstance():set("newPet_mid",mid)
				WildDataProxy:getInstance():set("newPet_form",form)
				if self.listenerPet4 then
					self:getEventDispatcher():removeEventListener(self.listenerPet4)
					self.listenerPet4 = nil
				end
				local listener = cc.EventListenerCustom:create("new_pet_4", confirmHandler)
				self.listenerPet4 = listener
			    local dispatcher = cc.Director:getInstance():getEventDispatcher()
			    dispatcher:addEventListenerWithFixedPriority(listener, 1)
				Utils.runUIScene("NewPetPopup")
			else
				local newPet = true
				local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
				for i,pet in pairs(petContent) do
					if pet:get("mid") == mid and pet:get("form") == form then
						newPet = false
						break
					end
				end
				if newPet and result.flag == 1 then
					GuideManager.guide_pet = 0
					WildDataProxy:getInstance():set("newPet_mid",mid)
					WildDataProxy:getInstance():set("newPet_form",form)
					if NormalDataProxy:getInstance().confirmHandler then
						NormalDataProxy:getInstance().confirmHandler = nil
					end
					NormalDataProxy:getInstance().confirmHandler = function( )
						local event = cc.EventCustom:new("event_battle_capture")
						event._usedata = {result = result, pet = pet}
						cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
					end
					Utils.runUIScene("NewPetPopup")
				else
					local event = cc.EventCustom:new("event_battle_capture")
					event._usedata = {result = result, pet = pet}
					cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
				end
			end
		end
		layoutSpine:runAction(cc.Sequence:create(cc.CallFunc:create(runSpine),cc.DelayTime:create(1),cc.CallFunc:create(runVisbilef),cc.DelayTime:create(7),cc.CallFunc:create(captureDone)))
	end

	local function event_capture_superball( p_sender )
		
		if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
			NetManager.sendCmd("guidepetreward",onCapture)
		else
			-- NetManager.sendCmd("capturepet", onCapture, pet.id, 2)
			if catching  == true then
				return 
			end
			if super_ball <=0 then
				if Player:getInstance():get("diamond") < 100 then
					TipManager.showTip("当前钻石不足")
					return
				end
				-- TipManager.showTip("物品数量不足")
				local diamondCapture = ConfigManager.getStageCommonConfig('advanced_diamond')
				GoldhandDataProxy:getInstance():set("usediamondnum",diamondCapture)
				GoldhandDataProxy:getInstance():set("goldhandtimes",1)
				GoldhandDataProxy:getInstance():set("isborrow",1)
				Utils.runUIScene("SecondensurePopup")
				if self.listener then
					self:getEventDispatcher():getEventDispatcher():removeEventListener(self.listener)
    				self.listener = nil
				end
				local listener = cc.EventListenerCustom:create("capture_second_ensure", function( )
					ball_type = 2
					NetManager.sendCmd("capturepet", onCapture, pet.id, 2)
					local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
					local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
					btnSuper:setEnabled(false)
					btnNormal:setEnabled(false)
					GoldhandDataProxy:getInstance():set("isborrow",0)
					listener = nil
				end)
				self.listener = listener
  				local dispatcher = cc.Director:getInstance():getEventDispatcher()
   				dispatcher:addEventListenerWithFixedPriority(listener, 1)
				
				-- return
			else
				-- catching  = true
				ball_type = 2
				NetManager.sendCmd("capturepet", onCapture, pet.id, 2)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				btnSuper:setEnabled(false)
				btnNormal:setEnabled(false)
			end
		end
	end

	local function event_capture_normalball( p_sender )
		
		if catching  == true then
			return
		end
		if normal_ball <=0 then
			if Player:getInstance():get("diamond") < 100 then
				TipManager.showTip("当前钻石不足")
				return
			end
			local diamondCapture = ConfigManager.getStageCommonConfig('advanced_diamond')
			GoldhandDataProxy:getInstance():set("usediamondnum",diamondCapture)
			GoldhandDataProxy:getInstance():set("goldhandtimes",1)
			GoldhandDataProxy:getInstance():set("isborrow",1)
			Utils.runUIScene("SecondensurePopup")
			if self.listener then
				self:getEventDispatcher():getEventDispatcher():removeEventListener(self.listener)
				self.listener = nil
			end
			local listener = cc.EventListenerCustom:create("capture_second_ensure", function( )
				ball_type = 1
				NetManager.sendCmd("capturepet", onCapture, pet.id, 1)
				local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
				local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
				btnSuper:setEnabled(false)
				btnNormal:setEnabled(false)
				GoldhandDataProxy:getInstance():set("isborrow",0)
				listener = nil
			end)
			self.listener = listener
			local dispatcher = cc.Director:getInstance():getEventDispatcher()
			dispatcher:addEventListenerWithFixedPriority(listener, 1)
		else
			ball_type = 1
			catching  = true
			NetManager.sendCmd("capturepet", onCapture, pet.id, 1)
			local btnNormal = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_NORMALBALL)
			local btnSuper = layoutBottom:getChildByTag(Tag_popup_capturepet.BTN_SUPERBALL)
			btnNormal:setEnabled(false)
			btnSuper:setEnabled(false)
		end
	end
	btnNormal:setOnClickScriptHandler(event_capture_normalball)
	btnSuper:setOnClickScriptHandler(event_capture_superball)

	if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.CAPTURE  then
		btnNormal:setEnabled(false)
        btnNormal:setColor(cc.c3b(86,86,86))
        btnSuper:setColor(cc.c3b(86,86,86))
        btnGiveUp:setEnabled(false)
        btnGiveUp:setColor(cc.c3b(86,86,86))
	end

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			TouchEffect.addTouchEffect(self)
		end
		if "enterTransitionFinish"  == event then
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.CAPTURE then
				local function dispatchHandler( )
					Utils.dispatchCustomEvent("event_enter_view",{view = "CaptureUI",phase = GuideManager.MAIN_GUIDE_PHASES.CAPTURE,scene = self})
				end
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(dispatchHandler)))
			end
		end	
	end
	self:registerScriptHandler(onNodeEvent)
end