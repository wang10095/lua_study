require "view/tagMap/Tag_ui_preset"

PresetUI = class("PresetUI", function()
	return TuiBase:create()
end) 

PresetUI.__index = PresetUI
local  __instance = nil
PresetUI.model = 0
PresetUI.sex = 0
PresetUI.editFinish = false
PresetUI.randFinish = false
function PresetUI:create()
	local ret = PresetUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PresetUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PresetUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_preset.PANEL_PRESET then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function PresetUI:dtor( )
	self:getEventDispatcher():removeEventListener(self.listenerNew)
end
function PresetUI:guidePlayer()
	local layoutBoy = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOY)
	local layoutGirl = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_GIRL)
	
	local jsonBoy = TextureManager.RES_PATH.SPINE_BOY..".json"
	local atlasBoy = TextureManager.RES_PATH.SPINE_BOY..".atlas"
	spineBoy = sp.SkeletonAnimation:create(jsonBoy, atlasBoy, 0.9)
	spineBoy:setAnimation(0, "part2", true)
	spineBoy:setScaleX(-1)
	local sizeBoy = layoutBoy:getContentSize()
	spineBoy:setPosition(cc.p(sizeBoy.width/2,sizeBoy.height/2))
	layoutBoy:addChild(spineBoy)


	local jsonGirl = TextureManager.RES_PATH.SPINE_GIRL..".json"
	local atlasGirl = TextureManager.RES_PATH.SPINE_GIRL..".atlas"
	spineGirl = sp.SkeletonAnimation:create(jsonGirl, atlasGirl, 0.9)
	spineGirl:setAnimation(0, "part2", true)
	local sizeGirl = layoutGirl:getContentSize()
	spineGirl:setPosition(cc.p(sizeGirl.width/2+30,sizeGirl.height/2))
	layoutGirl:addChild(spineGirl)

	local layoutBottomPlayer = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PLAYER)
	-- Utils.floatToBottom(layoutBottomPlayer)
	
	local labTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAB_TIPS)

	local editWord = layoutBottomPlayer:getChildByTag(Tag_ui_preset.EDIT_WORD)
	editWord:setColor(cc.c3b(235,235,235))

	local function event_edit(strEventName,pSender)
		local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS2)
		layoutTips:setVisible(false)
		if strEventName == "began" or strEventName == "changed" then
			-- __instance.editFinish = false
			-- local lab = CLabel:create()
			-- lab:setContentSize(cc.size(editWord:getContentSize()))
			-- lab:setPosition(cc.p(editWord:getContentSize().width/2,editWord:getContentSize().height/2))
			-- editWord:addChild(lab,1)
			-- lab:setString(editWord:getText())
			
		elseif strEventName == "return" then
			print(pSender:getText())
			__instance.editFinish = true
		end
	end
	editWord:registerScriptEditBoxHandler(event_edit)

	local btnDice = layoutBottomPlayer:getChildByTag(Tag_ui_preset.BTN_DICE)
	btnDice:setOnClickScriptHandler(function( p_sender )
		local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS2)
		layoutTips:setVisible(false)
		
		local function randomname( result )
			editWord:setText(result["name"])
			__instance.randFinish = true
		end
		NetManager.sendCmd("randomname",randomname)
	end)

	for i=1,2 do
		local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset["LAYOUT_TIPS"..i])
		layoutTips:setVisible(false)
	end
	
	local tgvGirl = layoutBottomPlayer:getChildByTag(Tag_ui_preset.TGV_GIRL)
	local tgvBoy = layoutBottomPlayer:getChildByTag(Tag_ui_preset.TGV_BOY)
	
	local imgSelect1 = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
	local size = tgvBoy:getContentSize()
	imgSelect1:setPosition(cc.p(size.width-35,30))
	tgvBoy:addChild(imgSelect1,2)
 	imgSelect1:setVisible(false)

	local imgSelect2 = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
	local size = tgvGirl:getContentSize()
	imgSelect2:setPosition(cc.p(size.width-35,30))
	tgvGirl:addChild(imgSelect2,2)
	imgSelect2:setVisible(false)
	local role = {}
	local function loadunlockedrole( result )
		role = result["role"]
	end
	NetManager.sendCmd("loadunlockedrole",loadunlockedrole)
	tgvBoy:setOnClickScriptHandler(function( p_sender )
		spineBoy:setAnimation(0, "part1", true)
		spineGirl:setAnimation(0, "part2", true)
		local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS1)
		layoutTips:setVisible(false)
		__instance.sex = 1
		print("boy")
		imgSelect1:setVisible(true)
		imgSelect2:setVisible(false)
		local function changerole( result )
			Player:getInstance():set("sex",1)
			Player:getInstance():set("role",1)
		end
		NetManager.sendCmd("changerole",changerole,1,1)
	end)

	tgvGirl:setOnClickScriptHandler(function( p_sender )
		spineGirl:setAnimation(0, "part1", true)
		spineBoy:setAnimation(0, "part2", true)
		local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS1)
		layoutTips:setVisible(false)
		__instance.sex = 2
		print("girl")
		imgSelect1:setVisible(false)
		imgSelect2:setVisible(true)
		local function changerole( result )
			Player:getInstance():set("sex",2)
			Player:getInstance():set("role",4)
		end
		NetManager.sendCmd("changerole",changerole,4,2)
	end)

	local btnEnsure = layoutBottomPlayer:getChildByTag(Tag_ui_preset.BTN_ENSURE)
	btnEnsure:setOnClickScriptHandler(function ( p_sender )

		if editWord:getText() ~= "" and __instance.sex ~= 0 then
			print(editWord:getText())	

			local function saveguidestatus( result )
				TDGAAccount:setAccount(Player:getInstance():get("uid"))
				TDGAAccount:setGender(Player:getInstance():get("sex"))
				GuideManager.main_guide_phase_ = 2
			end
			NetManager.sendCmd("saveguidestatus",saveguidestatus,2,4294967295)		
			local function event_callback_change_name( result )
				Player:getInstance():set("sex",__instance.sex)
				Player:getInstance():set("nickname",editWord:getText())
				if __instance.sex == 1 then
					Player:getInstance():set("role",1)
				elseif __instance.sex == 2 then
					Player:getInstance():set("role",4)
				end
				local layoutBoy = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOY)
				layoutBoy:setVisible(false)
				local layoutGirl = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_GIRL)
				layoutGirl:setVisible(false)
				local layoutBottomPlayer = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PLAYER)
				layoutBottomPlayer:setVisible(false)
				local function onGuidePet()
					__instance:guidePet()
				end
				Utils.dispatchCustomEvent("enter_view",{callback = onGuidePet, params = {view = "view", scene=2}})
			end
			NetManager.sendCmd("changename",event_callback_change_name,editWord:getText())
			-- Utils.dispatchCustomEvent("event_enter_view",{view = "PresetUI",phase = 2,scene = self})
		elseif __instance.sex == 0 then
			local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS1)
			layoutTips:setVisible(true)
		elseif editWord:getText() == "" then
		
			local layoutTips = layoutBottomPlayer:getChildByTag(Tag_ui_preset.LAYOUT_TIPS2)
			layoutTips:setVisible(true)
			
			local labTips = layoutTips:getChildByTag(Tag_ui_preset.LAB_NAME_TIPS)
			if editWord:getText() == ""  then
				labTips:setString("请输入您的昵称")
			end
		end
	end)
end
local function event_circleMenu_click( p_sender )
	local tag = p_sender:getTag()
	print(tag)
	local config = ConfigManager.getGuidePetConfig(tag)
	local petConfig = ConfigManager.getPetFormConfig(config.mid,1)
	local layoutBottomPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PET)
	local labPetInfo = layoutBottomPet:getChildByTag(Tag_ui_preset.LAB_PET_INFO)
	local labPetName = layoutBottomPet:getChildByTag(Tag_ui_preset.LAB_PET_NAME)

	local name = TextManager.getPetName(config.mid,1)
	labPetName:setString(name)
	local desc = TextManager.getPetDesc(config.mid,1)
	labPetInfo:setString(desc)

	__instance.model = tag 
end

function PresetUI:guidePet()
	local layoutPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_PETVIEW)
	
	layoutPet:setVisible(true)
	__instance.model = 1
	local posTable = {}
	local petTable = {}
	local maskTable ={}
	for i=1,3 do
		local config = ConfigManager.getGuidePetConfig(i)
		local petConfig = ConfigManager.getPetFormConfig(config.mid,1)
		local pet = layoutPet:getChildByTag(Tag_ui_preset["LAYOUT_PET"..i])
		local imgPet = TextureManager.createImg("portrait/".. petConfig.model ..".png")
		Utils.addCellToParent(imgPet,pet,true)
		
		local labPetName = layoutPet:getChildByTag(Tag_ui_preset["LAB_PET"..i.."_NAME"])
		local name = TextManager.getPetName(config.mid,1)
		labPetName:setString(name)

		local labPetInfo = layoutPet:getChildByTag(Tag_ui_preset["LAB_PET"..i.."_INFO"])
		local desc = TextManager.getPetDesc(config.mid,1)
		labPetInfo:setString(desc)

		table.insert(posTable,cc.p(pet:getPosition()))
		table.insert(petTable,pet)

		local tgvPet = layoutPet:getChildByTag(Tag_ui_preset["TGV_PET"..i])
		if i == 1 then
			tgvPet:setChecked(true)
		end
		if i == 2 then
			pet:setScale(0.8)
		end

		tgvPet:setOnClickScriptHandler(function( )
			__instance.model = i 
		end)
	end

	local layoutBottomPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PET)
	-- Utils.floatToBottom(layoutBottomPet)
	layoutBottomPet:setVisible(true)


	local btnSure = layoutBottomPet:getChildByTag(Tag_ui_preset.BTN_PETSURE)
	btnSure:setOnClickScriptHandler(function ( p_sender )
		
		NetManager.sendCmd("saveguidepet",function ( result )
			local config = ConfigManager.getGuidePetConfig(__instance.model)
			
			ItemManager.addPet({id =result["id"],mid  = config.mid,aptitude = config.aptitude,character = config.character,attributeGrowths = config.grow_random})
		
			NetManager.sendCmd("saveguidestatus",function (result)
			end,3,4294967295)
			
			--预设场景3
			local function confirmHandler()
				GuideManager.main_guide_phase_ = 3
				local layoutPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_PETVIEW)
				local layoutBottomPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PET)
				local layoutBoy = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOY)
				local layoutGirl = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_GIRL)
				local layoutBottomPlayer = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PLAYER)
				layoutBottomPet:setVisible(false)
				layoutPet:setVisible(false)
				layoutBoy:setVisible(false)
				layoutGirl:setVisible(false)
				layoutBottomPlayer:setVisible(false)
				local function onBattle()
					StageRecord:getInstance():set("chapter",1)
					StageRecord:getInstance():set("stage",1)
					Utils.replaceScene("BattleUI",__instance)
					MusicManager.battlebackground()
				end
				Utils.dispatchCustomEvent("enter_view",{callback = onBattle, params = {view = "view", scene = GuideManager.main_guide_phase_ }})
			end
			WildDataProxy:getInstance():set("newPet_mid",config.mid)
			WildDataProxy:getInstance():set("newPet_form",1)
			GuideManager.guide_pet = 1
			if __instance.listenerNew then
				__instance:getEventDispatcher():removeEventListener(self.listenerNew)
				__instance.listenerNew = nil
			end
			local listener = cc.EventListenerCustom:create("new_pet_1", confirmHandler)
			__instance.listenerNew = listener
		    local dispatcher = cc.Director:getInstance():getEventDispatcher()
		    dispatcher:addEventListenerWithFixedPriority(listener, 1)
			Utils.runUIScene("NewPetPopup")
		end,__instance.model)
	end)
end

function PresetUI:onLoadScene()
	--预设场景1
	TuiManager:getInstance():parseScene(self,"panel_preset",PATH_UI_PRESET)
	local layoutPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_PETVIEW)
	local layoutBottomPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PET)
	local layoutBoy = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOY)
	local layoutGirl = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_GIRL)
	local layoutBottomPlayer = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PLAYER)
	layoutBottomPet:setVisible(false)
	layoutPet:setVisible(false)
	layoutBoy:setVisible(false)
	layoutGirl:setVisible(false)
	layoutBottomPlayer:setVisible(false)

	local function onNodeEvent(event)
		if "enter" == event then

		elseif "enterTransitionFinish"  == event then
			print(" enterTransitionFinish ", GuideManager.main_guide_phase_)

			local callfunc = function()
				if GuideManager.main_guide_phase_ == 1 then
					--layout_player
					self:guidePlayer()
					layoutBoy:setVisible(true)
					layoutGirl:setVisible(true)
					layoutBottomPlayer:setVisible(true)
					local layoutPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_PETVIEW)
					layoutPet:setVisible(false)
					local layoutBottomPet = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PET)
					layoutBottomPet:setVisible(false)
				else
				  	--layout_pet
				  	self:guidePet()
					local layoutBoy = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOY)
					layoutBoy:setVisible(false)
					local layoutGirl = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_GIRL)
					layoutGirl:setVisible(false)
					local layoutBottomPlayer = __instance:getControl(Tag_ui_preset.PANEL_PRESET,Tag_ui_preset.LAYOUT_BOTTOM_PLAYER)
					layoutBottomPlayer:setVisible(false)
				end
				if GuideManager.main_guide_phase_ == 1 then
					TDGAMission:onBegin("新手引导")
					Utils.dispatchCustomEvent("event_enter_view",{view = "PresetUI",phase = 1,scene = self})
				else
					Utils.dispatchCustomEvent("event_enter_view",{view = "PresetUI",phase = 2,scene = self})
				end
			end
			Utils.dispatchCustomEvent("enter_view",{callback = callfunc, params = {view = "view", scene = 1}})

		elseif "exit" == event then
			
		end
	end
	self:registerScriptHandler(onNodeEvent)
end
