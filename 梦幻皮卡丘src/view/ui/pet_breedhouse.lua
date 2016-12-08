require "view/tagMap/Tag_ui_pet_breedhouse"

PetBreedHouse = class("PetBreedHouse",function()
	return TuiBase:create()
end)

PetBreedHouse.__index = PetBreedHouse
local __instance = nil
local hasSpecailBreed = false --特殊融合完成
local isBreeding = false  --是否正在融合 融合特效执行过程中  点击按钮无效
local breedType = 0 --融合的类型
local btnOrdinaryBreed 
local btnSpecialBreed 
local btnPetInherit
local winSize =  nil
local middlePosition = 300
local gvCotent = {}
local cultivateOldAptitude = 0

function PetBreedHouse:create()
	local ret = PetBreedHouse.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetBreedHouse:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetBreedHouse:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_breedhouse.PANEL_BREED then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function eventBackMainUI()
	if isBreeding ==true then
		return
	end
	local gvCotent =  ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	for i,v in ipairs(gvCotent) do
		if v:get("id")~=nil then
			v:set("isSelected",0)
		end
	end
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.replaceScene("MainUI",__instance)
end

local function event_function(pSender)
	if isBreeding == true then
		if breedType==1 then
			btnOrdinaryBreed:setChecked(true) 
		elseif breedType==2 then
			btnSpecialBreed:setChecked(true) 
		elseif breedType==3 then
			btnPetInherit:setChecked(true)
		end
		return
	end
	local tag = pSender:getTag()
	local k = {
		Tag_ui_pet_breedhouse.TGV_BREED1,
		Tag_ui_pet_breedhouse.TGV_BREED2,
		Tag_ui_pet_breedhouse.TGV_BREED3
	}  
	layoutOrdinaryBreed:setVisible(tag == k[1])
	layoutSpecialBreed:setVisible(tag == k[2])
	layoutPetInHerit:setVisible(tag == k[3])
	local labTalk = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_NPC_TALK)
	labTalk:setVisible(false)
	local labSpecial = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_SPECIAL_TALK)
	labSpecial:setVisible(false)
	local labInherit = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_INHERIT_TALK)
	labInherit:setVisible(false)
	local lab = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_INIT_TALK)
	lab:setVisible(false)
	local imgPeople = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.IMG_BREEDNPC)
	
	if tag == k[1] then
		__instance:petOrdinaryBreed()
		labTalk:setVisible(true)
		labTalk:setString("")
		NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.NormalBreed)
		NpcTalkManager.setNPCTouch(__instance,imgPeople,labTalk,NpcTalkManager.SCENE.NormalBreed)
	elseif tag == k[2] then
		__instance:petSpecialBreed()	
		labSpecial:setVisible(true)
		labSpecial:setString("")
		NpcTalkManager.initTalk(labSpecial,NpcTalkManager.SCENE.SpecialBreed)
		NpcTalkManager.setNPCTouch(__instance,imgPeople,labSpecial,NpcTalkManager.SCENE.SpecialBreed)	
	elseif tag == k[3] then
		__instance:petInherit() 
		labInherit:setVisible(true)
		labInherit:setString("")
		NpcTalkManager.initTalk(labInherit,NpcTalkManager.SCENE.Inherit)
		NpcTalkManager.setNPCTouch(__instance,imgPeople,labInherit,NpcTalkManager.SCENE.Inherit)		
	end
end

local function event_callback_ordinary_breed(result)
	isBreeding = true  --正在融合
	breedType = 1
	local layoutSpine = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.LAYOUT_SPINE1)
	layoutSpine:removeAllChildren()
	local function runBreedAction()
		local effectLayout = cc.Sprite:create("spine/spine_breedhouse/breedhouse02/rh02_0001.png")
	    local size = layoutSpine:getContentSize()
	    effectLayout:setPosition(cc.p(size.width/2,size.height/2))
	    effectLayout:setScale(4)
	    layoutSpine:addChild(effectLayout,10)
	    
		local animation = cc.Animation:create()
		local name
		for i=1,49,1 do
			name = string.format(TextureManager.RES_PATH.BREEDHOUSE_02,i)
			animation:addSpriteFrameWithFile(name)
		end
		animation:setDelayPerUnit(0.06)
		local action = cc.Animate:create(animation)
		local function releaseAction( )
			layoutSpine:removeChild(effectLayout)
		end
		effectLayout:runAction(cc.Sequence:create(action, cc.DelayTime:create(2.5),cc.CallFunc:create(releaseAction)))
	end
	local function callback()
		local labLuckNum = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_LUCK_NUM)
		labLuckNum:setString(result["lucknum"])
		for i,id in pairs(result["consumed_pet_ids"]) do
			ItemManager.removePetById(id)
		end
		ItemManager.addPet(result["pet"])
		local gvCotent =  ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
		for i,v in ipairs(gvCotent) do
			if result["pet"]["id"] == v:get("id") then
				ItemManager.currentPet = v
			end
		end
		PetBreedProxy:getInstance().petOrdinaryBreed = {0,0,0,0}  --重置
		__instance:petOrdinaryBreed()
		Utils.runUIScene("BreedResultPopup")
		isBreeding = false 
		breedType = 0
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(runBreedAction),cc.DelayTime:create(2.7),cc.CallFunc:create(callback)))
end

local function event_ordinary_breed(pSender)
    local gvCotentPets = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
    local count = #gvCotentPets
   	for k,v in ipairs(gvCotentPets) do
   		if v:get("id")==nil then
   			count = count - 1
   		end
   	end

   	if count - 3 < 5 then
   		TipManager.showTip("融合后宠物数量不足以上阵")
   		return
   	end
	local proxy = PetBreedProxy:getInstance()
	local ordinaryPets = proxy.petOrdinaryBreed
	for i,v in ipairs(ordinaryPets) do
		if v:get("aptitude")>3 then
		    local proxy = NormalDataProxy:getInstance()
		    proxy:set("title","融合警示")
		    proxy:set("content","选中的宠物内包含紫色或更高品质的宠物。是否继续融合？")
		    local function confirmHandler()
		        local petIdTable = {ordinaryPets[1]:get("id"),ordinaryPets[2]:get("id"),ordinaryPets[3]:get("id"),ordinaryPets[4]:get("id")}
				MusicManager.breed() --融合音效 
				NetManager.sendCmd("petbreed",event_callback_ordinary_breed,petIdTable)
		    end
		    proxy.confirmHandler = confirmHandler
		    Utils.runUIScene("NormalPopup")
			return
		end
	end

	local petIdTable = {ordinaryPets[1]:get("id"),ordinaryPets[2]:get("id"),ordinaryPets[3]:get("id"),ordinaryPets[4]:get("id")}
	MusicManager.breed() --融合音效 
	NetManager.sendCmd("petbreed",event_callback_ordinary_breed,petIdTable)
	return
end

local function event_callback_special_breed(result)
	isBreeding = true  --正在融合
	hasSpecailBreed = true
	breedType = 2
	local layoutSpine = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAYOUT_SPINE2)
	layoutSpine:removeAllChildren()
	local function runBreedAction()
		local effectLayout = cc.Sprite:create("spine/spine_breedhouse/breedhouse03/rh03_0001.png")
	    local size = layoutSpine:getContentSize()
	    effectLayout:setPosition(cc.p(size.width/2,size.height/2))
	    effectLayout:setScale(4)
	    layoutSpine:addChild(effectLayout,10)
	    
		local animation = cc.Animation:create()
		local name
		for i=1,41,2 do
			name = string.format(TextureManager.RES_PATH.BREEDHOUSE_03,i)
			animation:addSpriteFrameWithFile(name)
		end
		animation:setDelayPerUnit(0.1)
		local action = cc.Animate:create(animation)
		local function releaseAction( )
			layoutSpine:removeChild(effectLayout)
		end
		effectLayout:runAction(cc.Sequence:create(action, cc.DelayTime:create(1),cc.CallFunc:create(releaseAction)))
	end
	local function callback()
		ItemManager.removePetById(result["old_pet_id"])
		ItemManager.updatePet(result["new_pet_id"],{aptitude = result["aptitude"], attributeGrowths = result["attributeGrowths"] })
		PetBreedProxy:getInstance().addAttributeValue = result["addAttributeValue"]     --改变的属性值
		local gvCotent =  ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			for i,v in ipairs(gvCotent) do
				if result["new_pet_id"] == v:get("id") then
					ItemManager.currentPet = v
				end
			end
		PetBreedProxy:getInstance().petSpecialBreed[2] = 0    --重置
		__instance:petSpecialBreed()
		Utils.runUIScene("BreedResultPopup")
		breedType = 0
		isBreeding = false 
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(runBreedAction),cc.DelayTime:create(2),cc.CallFunc:create(callback)))
end

local function event_special_breed(pSender)
    local gvCotentPets = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
    local count = #gvCotentPets
   	for k,v in ipairs(gvCotentPets) do
   		if v:get("id")==nil then
   			count = count - 1
   		end
   	end
   	if count -1 <5 then
   		TipManager.showTip("融合后宠物数量不足以上阵")
   		return
   	end

	local proxy = PetBreedProxy:getInstance()
	local specialPets = proxy.petSpecialBreed

	local maxApit = ConfigManager.getPetGrowRandom(specialPets[1]:get("aptitude")).addedValueLimit
	local nowPetApit = specialPets[1]:get("attributeGrowths")[1]+specialPets[1]:get("attributeGrowths")[2]
	if nowPetApit >= maxApit then
		TipManager.showTip("培养对象资质已满")
		return
	end

	for i,v in ipairs(specialPets) do
		if v == 0 then
			TipManager.showTip("请选择宠物")
			return
		end
	end
	MusicManager.breed() --融合音效 
	NetManager.sendCmd("petspecialbreed",event_callback_special_breed,specialPets[2]:get("id"),specialPets[1]:get("id"))
end

local function event_callback_inherit(result)
	isBreeding = true  --正在传承
	breedType =  3
	local layoutSpine = layoutPetInHerit:getChildByTag(Tag_ui_pet_breedhouse.LAYOUT_SPINE3)
	layoutSpine:removeAllChildren()
	local function runBreedAction( )
		local effectLayout = cc.Sprite:create("spine/spine_breedhouse/breedhouse01/rh01_0001.png")
		local size = layoutSpine:getContentSize()
	    effectLayout:setPosition(cc.p(size.width/2,size.height/2))
	    effectLayout:setScale(4)
	    layoutSpine:addChild(effectLayout,10)
	    
		local animation = cc.Animation:create()
		local name
		for i=1,43,2 do
			name = string.format(TextureManager.RES_PATH.BREEDHOUSE_01,i)
			animation:addSpriteFrameWithFile(name)
		end
		animation:setDelayPerUnit(0.1)
		local action = cc.Animate:create(animation)
		local function releaseAction( )
			layoutSpine:removeChild(effectLayout)
		end
		effectLayout:runAction(cc.Sequence:create(action, cc.DelayTime:create(1),cc.CallFunc:create(releaseAction)))
	end
	local function callback()
		local inheritPets = PetBreedProxy:getInstance().petInherit
		ItemManager.removePetById(result["old_pet_id"])
		Player:getInstance():set("diamond",result["diamond"])
		Player:getInstance():set("gold",result["gold"])
		ItemManager.updatePet(inheritPets[1]:get("id"),result["pet"])
		local gvCotent =  ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			for i,v in ipairs(gvCotent) do
				if inheritPets[1]:get("id") == v:get("id") then
					ItemManager.currentPet = v
				end
			end
		PetBreedProxy:getInstance().petInherit = {0,0}
		__instance:petInherit()
		Utils.runUIScene("BreedResultPopup")
		breedType = 0
		isBreeding = false 
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(runBreedAction),cc.DelayTime:create(2),cc.CallFunc:create(callback)))

end

local function eventPetInherit(pSender) 
    local gvCotentPets = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
    local count = #gvCotentPets
   	for k,v in ipairs(gvCotentPets) do
   		if v:get("id")==nil then
   			count = count - 1
   		end
   	end

   	if count -1 <5 then
   		TipManager.showTip("传承后宠物数量不足以上阵")
   		return
   	end
	local proxy = PetBreedProxy:getInstance()
	local inheritPets = proxy.petInherit
	for i,v in ipairs(inheritPets) do
		if v == 0 then
			TipManager.showTip("请选择宠物")
			return
		end
	end
	MusicManager.breed() --融合音效 
	NetManager.sendCmd("petinherit",event_callback_inherit,inheritPets[2]:get("id"),inheritPets[1]:get("id"))
end

function PetBreedHouse:petOrdinaryBreed()

	local breedProxy = PetBreedProxy:getInstance() 
	for i = 1,4  do
		local imgPetBall = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse["IMG_PET_BALL" .. i])
		imgPetBall:removeAllChildren()
		local btnAddPet  = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse["BTN_ADD_PET" .. i])
	
		if breedProxy.petOrdinaryBreed[i] == 0 then
			btnAddPet:setOpacity(255)
			local fadeout =  cc.FadeTo:create(1.0,120)
			local fadein = cc.FadeIn:create(1.0)
			local sequence = cc.Sequence:create(fadeout,fadein,nil)
			btnAddPet:runAction(cc.RepeatForever:create(sequence))
		else
			btnAddPet:setOpacity(0)
			btnAddPet:stopAllActions()
			local pet  = breedProxy.petOrdinaryBreed[i]
			local petModel = ConfigManager.getPetFormConfig(pet:get("mid"),pet:get("form")).model
			local pet_ = Pet:create()
			pet_:set("mid",pet:get("mid"))
			pet_:set("form",pet:get("form"))
			pet_:set("model",petModel)
			pet_:set("aptitude", pet:get("aptitude"))
			local petCell = PetCell:create(pet_)
			petCell:setScale(1.3)
			Utils.addCellToParent(petCell,imgPetBall)
		end
		local function event_ordinary_head(pSender)
			local proxy = NormalDataProxy:getInstance()
			local function confirmHandler()
				__instance:petOrdinaryBreed()
			end
			proxy.confirmHandler = confirmHandler
			breedProxy:set("breedType",1)
			breedProxy:set("selectPopupType",1) --弹出框类型1   选择4个没有经过培养的神奇宝贝进行融合
			Utils.runUIScene("BreedSelectPetPopup")
		end
		btnAddPet:setOnClickScriptHandler(event_ordinary_head)
	end

	local layoutSpine = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.LAYOUT_SPINE1)
	layoutSpine:removeAllChildren()
	local atlas = "spine/spine_breedhouse/spine_breedhouse_middle.atlas"
	local json  = "spine/spine_breedhouse/spine_breedhouse_middle.json"
	local spine = sp.SkeletonAnimation:create(json, atlas)
	spine:setAnimation(0, "part1", true)
	Utils.addCellToParent(spine,layoutSpine)

	local btnBreed = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.BTN_BREED)
	local lab_common_breed = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_COMMON_BREED)
	local imgPetResult = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.IMG_PET_BALL_RESULT)
	imgPetResult:removeAllChildren()
	local imgQuestion = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.IMG_QUESTION)
	local commonPet = true --判断宠物是否同种
	local fullPets = true --判断宠物槽是否满
	for i,v in ipairs(breedProxy.petOrdinaryBreed) do
		if v == 0 then
			lab_common_breed:setVisible(false)
			btnBreed:setVisible(false)
			fullPets = false
			imgQuestion:setVisible(false)
		end
	end
	if fullPets == true then
		layoutSpine:removeAllChildren()
		local mid = breedProxy.petOrdinaryBreed[1]:get("mid")
		for i,v in ipairs(breedProxy.petOrdinaryBreed) do
			if mid ~= v:get("mid") then
				commonPet = false
			end
		end
	end	
	if commonPet == true and fullPets == true then	
		local petFormConfig = ConfigManager.getPetFormConfig(breedProxy.petOrdinaryBreed[1]:get("mid"), breedProxy.petOrdinaryBreed[1]:get("form"))
		local pet_ = Pet:create()
		pet_:set("mid",breedProxy.petOrdinaryBreed[1]:get("mid"))
		pet_:set("form",breedProxy.petOrdinaryBreed[1]:get("form"))
		pet_:set("aptitude",1)
		local petCell = PetCell:create(pet_)
		petCell:setScale(1.3)
		Utils.addCellToParent(petCell,imgPetResult)
		imgQuestion:setVisible(false)
		btnBreed:setVisible(true)
		lab_common_breed:setVisible(true)
	elseif commonPet == false and fullPets == true then
		imgQuestion:setVisible(true)
		btnBreed:setVisible(true)
		lab_common_breed:setVisible(true)
	end
	layoutOrdinaryBreed:setVisible(true)
	layoutSpecialBreed:setVisible(false)
	layoutPetInHerit:setVisible(false)
end

function PetBreedHouse:petAttributeShow() --属性展示
	local breedProxy = PetBreedProxy:getInstance()
	local cultivatePet = breedProxy.petSpecialBreed[1]--培养对象
	local consumePet = breedProxy.petSpecialBreed[2]--消耗对象
	local labLifeNum = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_LIFE_NUM)
	local labAttackNum = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_ATTACK_NUM)
	labLifeNum:setVisible(false)
	labAttackNum:setVisible(false)
	local labPetAptitude =  layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_SPECIAL_BREED_APTITUDE)
	local labLifeGrowNum = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_LIFE_GROW_NUM2)
	local labAttackGrowNum = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_ATTACK_GROW_NUM2)
	local labAptitudeNum = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_SPECIAL_APTITUDE_NUM)
	local labMaxAptitude = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_SPECIAL_MAX_APTITUDE)
	local labAddAptitude = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_SPECIAL_ADD_APTITUDE)
	labAptitudeNum:setVisible(false)
	labMaxAptitude:setVisible(false)
	labAddAptitude:setVisible(false)
	labPetAptitude:setVisible(false)
	labLifeGrowNum:setVisible(false)
	labAttackGrowNum:setVisible(false)
	labLifeGrowNum:setColor(cc.c3b(0,255,0))
	labAttackGrowNum:setColor(cc.c3b(0,255,0))
	labAddAptitude:setColor(cc.c3b(0,255,0))

	if cultivatePet ~= 0 and  hasSpecailBreed==false then
		cultivateOldAptitude = cultivatePet:getAptitudeNum()
		local petConfig = ConfigManager.getPetConfig(cultivatePet:get("mid"))
		labLifeNum:setVisible(true)
		labAttackNum:setVisible(true)
		labPetAptitude:setVisible(true)
		labAptitudeNum:setVisible(true)
		labMaxAptitude:setVisible(true)
		labLifeNum:setString(Utils.roundingOff(petConfig.star_attribute_growths[1][cultivatePet:get("star")]/100) .. "+" .. Utils.roundingOff(cultivatePet:get("attributeGrowths")[1]/100))
		labAttackNum:setString(Utils.roundingOff(petConfig.star_attribute_growths[2][cultivatePet:get("star")]/100) .. "+" .. Utils.roundingOff(cultivatePet:get("attributeGrowths")[2]/100))
		labPetAptitude:setString(TextManager.getPetAptitudeName(cultivatePet:get("aptitude")))
		labLifeNum:setColor(Constants.APTITUDE_COLOR[cultivatePet:get("aptitude")])
		labAttackNum:setColor(Constants.APTITUDE_COLOR[cultivatePet:get("aptitude")])
		labPetAptitude:setColor(Constants.APTITUDE_COLOR[cultivatePet:get("aptitude")])
		labAptitudeNum:setColor(Constants.APTITUDE_COLOR[cultivatePet:get("aptitude")])
		local aptitude = cultivatePet:getAptitudeNum()
		if aptitude >= Utils.getPetMaxAptitude(cultivatePet:get("aptitude")) then
			aptitude = '满'
		end
		labAptitudeNum:setString(aptitude)
		labMaxAptitude:setString("(" .. Utils.getPetMaxAptitude(cultivatePet:get("aptitude")) .. ")" )
	end 

	if cultivatePet ~= 0 and consumePet == 0 and hasSpecailBreed==true then --融合成功显示成长增加值  特殊融合成功
		hasSpecailBreed = false
		labLifeNum:setVisible(true)  
		labAttackNum:setVisible(true)
		labPetAptitude:setVisible(true)
		labLifeGrowNum:setVisible(true)
		labAttackGrowNum:setVisible(true)
		labAptitudeNum:setVisible(true)
		labMaxAptitude:setVisible(true)
		labAddAptitude:setVisible(true)
		labPetAptitude:setString(TextManager.getPetAptitudeName(cultivatePet:get("aptitude")))
		local aptitude = cultivatePet:getAptitudeNum()
		if aptitude >= Utils.getPetMaxAptitude(cultivatePet:get("aptitude")) then
			aptitude = '满'
		end
		labAptitudeNum:setString(aptitude)

		local petConfig = ConfigManager.getPetConfig(cultivatePet:get("mid"))
		labLifeNum:setString(Utils.roundingOff(petConfig.star_attribute_growths[1][cultivatePet:get("star")]/100) .. "+" .. Utils.roundingOff(cultivatePet:get("attributeGrowths")[1]/100))
		labAttackNum:setString(Utils.roundingOff(petConfig.star_attribute_growths[2][cultivatePet:get("star")]/100) .. "+" .. Utils.roundingOff(cultivatePet:get("attributeGrowths")[2]/100))

		if breedProxy.addAttributeValue[1]~=nil and aptitude-cultivateOldAptitude > 0 then
			labAddAptitude:setString("↑" .. aptitude-cultivateOldAptitude)
		elseif breedProxy.addAttributeValue[1]~=nil and aptitude-cultivateOldAptitude < 0 then
			labAddAptitude:setString("↓" .. cultivateOldAptitude-aptitude)
		else
			labAddAptitude:setVisible(false)
		end


		if breedProxy.addAttributeValue[1]~=nil and breedProxy.addAttributeValue[1] > 0 then
			labLifeGrowNum:setString("↑" .. Utils.roundingOff(breedProxy.addAttributeValue[1]/100))
		elseif breedProxy.addAttributeValue[1]~=nil and breedProxy.addAttributeValue[1]<0 then
			labLifeGrowNum:setString("↓" .. Utils.roundingOff(math.abs(breedProxy.addAttributeValue[1])/100))
		else
			labLifeGrowNum:setVisible(false)
		end

		if breedProxy.addAttributeValue[2]~=nil and breedProxy.addAttributeValue[2] > 0 then
			labAttackGrowNum:setString("↑" .. Utils.roundingOff(breedProxy.addAttributeValue[2]/100))
		elseif breedProxy.addAttributeValue[2]~=nil and breedProxy.addAttributeValue[2]<0 then
			labAttackGrowNum:setString("↓" .. Utils.roundingOff(math.abs(breedProxy.addAttributeValue[2])/100))
		else
			labAttackGrowNum:setVisible(false)
		end
		breedProxy.addAttributeValue = {}
	end
end

function PetBreedHouse:petSpecialBreed() --特殊融合 
	local breedProxy = PetBreedProxy:getInstance() 

	for i = 1 ,2 do
		local layout_special_breed = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse["LAYOUT_SPECIAL_BREED" .. i])
		local imgSpecialPet = layout_special_breed:getChildByTag(Tag_ui_pet_breedhouse["IMG_PET_SPECIAL_BALL" .. i])   
		imgSpecialPet:removeAllChildren()
		local btnAddPet = layout_special_breed:getChildByTag(Tag_ui_pet_breedhouse["BTN_SPECIAL_PET" .. i])   
		local lab_special_breed = layout_special_breed:getChildByTag(Tag_ui_pet_breedhouse["LAB_SPECIAL_BREED" .. i])   

		if breedProxy.petSpecialBreed[i] == 0 then
			btnAddPet:setOpacity(255)
			if i == 1  then
				lab_special_breed:setString("选择培育对象")
				layout_special_breed:setVisible(true)
			else
				if  breedProxy.petSpecialBreed[1] == 0  then
					layout_special_breed:setVisible(false)
				else
					layout_special_breed:setVisible(true)
					layout_special_breed:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition+140,layout_special_breed:getPositionY())))
				end
				lab_special_breed:setString("选择消耗材料")
			end
		else
			btnAddPet:setOpacity(0)
			layout_special_breed:setVisible(true)
			lab_special_breed:setColor(cc.c3b(255,255,255))
			if i ==  1 then
				lab_special_breed:setString("培育对象")
				layout_special_breed:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition-140,layout_special_breed:getPositionY())))
			else
				lab_special_breed:setString("消耗材料")
				layout_special_breed:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition+140,layout_special_breed:getPositionY())))
			end

			local pet  = breedProxy.petSpecialBreed[i]
			local petCell = PetCell:create(pet)
			petCell:setScale(1.3)
			Utils.addCellToParent(petCell,imgSpecialPet)
		end

		local function event_special_head(pSender)
			local tag = pSender:getTag()
			if tag == Tag_ui_pet_breedhouse.BTN_SPECIAL_PET2 and  breedProxy.petSpecialBreed[1] == 0 then
				-- TipManager.showTip("请选择培育对象")
				-- return 
			end
			local proxy = NormalDataProxy:getInstance()
			local function confirmHandler()
				__instance:petSpecialBreed()
			end
			proxy.confirmHandler = confirmHandler
			breedProxy:set("breedType",2)
			if i == 1 then
				breedProxy:set("selectPopupType",2)--选择培育对象
			else
				breedProxy:set("selectPopupType",3)--选择消耗材料
			end
			Utils.runUIScene("BreedSelectPetPopup")
		end
		btnAddPet:setOnClickScriptHandler(event_special_head)
	end
	self:petAttributeShow()

	layoutOrdinaryBreed:setVisible(false)
	layoutSpecialBreed:setVisible(true)
	layoutPetInHerit:setVisible(false)
end

function PetBreedHouse:petInherit()
	local breedProxy = PetBreedProxy:getInstance() 
	for i = 1 ,2 do
		local layout_inherit = layoutPetInHerit:getChildByTag(Tag_ui_pet_breedhouse["LAYOUT_INHERIT" .. i])
		local imgInheritPet = layout_inherit:getChildByTag(Tag_ui_pet_breedhouse["IMG_PET_INHERIT_BALL" .. i])
		imgInheritPet:removeAllChildren()

		local lab_inherit = layout_inherit:getChildByTag(Tag_ui_pet_breedhouse["LAB_INHERIT" .. i])
		local btnAddPet = layout_inherit:getChildByTag(Tag_ui_pet_breedhouse["BTN_INHERIT_PET" .. i])   
		if breedProxy.petInherit[i] == 0 then
			btnAddPet:setOpacity(255)
			if i == 1  then
				lab_inherit:setString("选择继承者")
				layout_inherit:setVisible(true)
				layout_inherit:setPositionX(middlePosition)
			else
				if breedProxy.petInherit[1] == 0 then
					layout_inherit:setVisible(false)
				else
					layout_inherit:setVisible(true)
					layout_inherit:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition+140,layout_inherit:getPositionY())))
				end
				lab_inherit:setString("选择传承者")
			end
		else
			btnAddPet:setOpacity(0)
			layout_inherit:setVisible(true)
			lab_inherit:setColor(cc.c3b(255,255,255))
			if i ==  1 then
				lab_inherit:setString("继承者")
				layout_inherit:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition-140,layout_inherit:getPositionY())))
			else
				lab_inherit:setString("传承者")
				layout_inherit:runAction(cc.MoveTo:create(0.5,cc.p(middlePosition+140,layout_inherit:getPositionY())))
			end

			local pet  = breedProxy.petInherit[i]
			local petCell = PetCell:create(pet)
			petCell:setScale(1.3)
			Utils.addCellToParent(petCell,imgInheritPet)
		end

		local function event_inherite_head(pSender)
			local tag = pSender:getTag()
			if tag == Tag_ui_pet_breedhouse.BTN_INHERIT_PET2 and  breedProxy.petInherit[1] == 0 then
				-- TipManager.showTip("请先选择继承者")
				-- return 
			end
			local proxy = NormalDataProxy:getInstance()
			local function confirmHandler()
				__instance:petInherit()
				if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT) == false 
					and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_HRIR) then
					Utils.dispatchCustomEvent("event_breed",{view = "PetBreedHouse",phase = GuideManager.FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT,scene = self})
				elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT) == true 
					and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.INHERIT) == false then
					Utils.dispatchCustomEvent("enter_view",{callback = function ( )
						Utils.dispatchCustomEvent("event_breed",{view = "PetBreedHouse",phase = GuideManager.FUNC_GUIDE_PHASES.INHERIT,scene = self})
					end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.INHERIT}})	
				end
			end
			proxy.confirmHandler = confirmHandler
			breedProxy:set("breedType",3)
			if i == 1 then
				breedProxy:set("selectPopupType",4)
				if breedProxy.petInherit[1]~=0 and breedProxy.petInherit[2]~=0 then
					local oldPetId = breedProxy.petInherit[1]:get("id")
					local function updateInherit() --重新选择继承者  清空传承者
						if  breedProxy.petInherit[1]:get("id") ~= oldPetId then
							breedProxy.petInherit[2] = 0
						end
					end
					PetBreedProxy:getInstance().updateInherit = updateInherit
				end
			else
				breedProxy:set("selectPopupType",2)
			end
			Utils.runUIScene("BreedSelectPetPopup")
		end
		btnAddPet:setOnClickScriptHandler(event_inherite_head)
	end
	local costDiamond = layoutPetInHerit:getChildByTag(Tag_ui_pet_breedhouse.LAB_DIAMOND_NUM)
	costDiamond:setString(ConfigManager.getPetCommonConfig('inherit_diamond'))
	local img_diamond = layoutPetInHerit:getChildByTag(Tag_ui_pet_breedhouse.IMG_DIAMOND)
	if breedProxy.petInherit[1]~=0 then
		img_diamond:setVisible(true)
		local costConfig = ConfigManager.getPetInheritCostConfig(breedProxy.petInherit[1]:get("aptitude"))
		if costConfig.gold == 0 then
			img_diamond:setSpriteFrame("component_common/img_diamond.png")
			costDiamond:setString(costConfig.diamond)
		else
			img_diamond:setSpriteFrame("component_common/img_gold.png")
			costDiamond:setString(costConfig.gold)
		end
	end
	if breedProxy.petInherit[1]==0 then
		img_diamond:setVisible(false)
		costDiamond:setString("?")
	end
	
	layoutOrdinaryBreed:setVisible(false)
	layoutSpecialBreed:setVisible(false)
	layoutPetInHerit:setVisible(true)
end

local function eventAllPetSelect() --一键选择未被培养的宠物资质最小的四个
	local limitVip = ConfigManager.getRechargeCommonConfig('vip_level_auto_select_breed')
	if Player:getInstance():get("vip")<limitVip then
		TipManager.showTip("VIP等级达到" .. limitVip .. "后开放")
		return
	end
	local gvCotent = {}
	local gvCotentPet = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	for i,v in ipairs(gvCotentPet) do
		if v:get("id")~=nil then
			table.insert(gvCotent, v)	
		end
	end

	for i = #gvCotent,1,-1  do  --未经过培养的宠物   并且不能出现资质>3
		if gvCotent[i]:get("level")~=1 or gvCotent[i]:get("rank")~=1 or gvCotent[i]:get("star")~=1 or gvCotent[i]:get("aptitude")>3  then
			table.remove(gvCotent,i)
		else
			local skillLevels = gvCotent[i]:get("skillLevels")
				for j = #skillLevels,1,-1 do
					if skillLevels[j] ~= 1 then
					table.remove(gvCotent,i)
					break
				end
			end
		end
	end

	function event_sortPets(a,b)
		local aaa,bbb = a:get("attributeGrowths"),b:get("attributeGrowths") --先资质后mid
		if  (aaa[1]+aaa[2]) == (bbb[1]+bbb[2])  then
			return a:get("mid")<b:get("mid")
		else
			return (aaa[1]+aaa[2]) < (bbb[1]+bbb[2]) 
		end
	end
	table.sort(gvCotent, event_sortPets)
	if #gvCotent<4 then
		TipManager.showTip("紫色以下品质宠物数量不足")
		return
	end
	for i = 1,4 do
		PetBreedProxy:getInstance().petOrdinaryBreed[i] = gvCotent[i]
		PetBreedProxy:getInstance().petOrdinaryBreed[i]:set("isSelected",4+1-i)
		-- print("===一键选择的宠物id====" .. gvCotent[i]:get("id"))
	end
	__instance:petOrdinaryBreed()
end

function PetBreedHouse:EventFunction()
	local btnBreed = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.BTN_BREED)
	btnBreed:setOnClickScriptHandler(event_ordinary_breed)
	local btnPetSpecialBreed = layoutSpecialBreed:getChildByTag(Tag_ui_pet_breedhouse.BTN_SPECIAL_BREED)
	btnPetSpecialBreed:setOnClickScriptHandler(event_special_breed)
	local btnInherit = layoutPetInHerit:getChildByTag(Tag_ui_pet_breedhouse.BTN_PETINHERIT)
	btnInherit:setOnClickScriptHandler(eventPetInherit)

	local btn_all_select = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.BTN_YELLOW)
	btn_all_select:setOnClickScriptHandler(eventAllPetSelect)

	btnBreed:setScale(1.3)
	btnPetSpecialBreed:setScale(1.3)
	btnInherit:setScale(1.3)
end

function PetBreedHouse:onLoadScene()
	winSize = cc.Director:getInstance():getWinSize()
	local breedProxy = PetBreedProxy:getInstance()
	breedProxy.petOrdinaryBreed = {0,0,0,0} --初始化
	breedProxy.petSpecialBreed = {0,0}
	breedProxy.petInherit = {0,0}
	TuiManager:getInstance():parseScene(self,"panel_breed",PATH_UI_PET_BREEDHOUSE)
	-- labTalk = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_NPC_TALK)
	-- labTalk:setVerticalAlignment(1)

	local layoutButtom = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAYOUT_BUTTOM)
	Utils.floatToBottom(layoutButtom)
	local btnBack = layoutButtom:getChildByTag(Tag_ui_pet_breedhouse.BTN_BACK)
	btnBack:setOnClickScriptHandler(eventBackMainUI)

	local imgPeople = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.IMG_BREEDNPC)
	-- NpcTalkManager.setNPCTouch(__instance,imgPeople,labTalk,NpcTalkManager.SCENE.NormalBreed)

	local layoutAction = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAYOUT_SPINE_ACTION)
	Spine.addSpine(layoutAction,"breedhouse","corner","part1",true)

	btnOrdinaryBreed = layoutButtom:getChildByTag(Tag_ui_pet_breedhouse.TGV_BREED1)
	btnSpecialBreed = layoutButtom:getChildByTag(Tag_ui_pet_breedhouse.TGV_BREED2)
	btnPetInherit = layoutButtom:getChildByTag(Tag_ui_pet_breedhouse.TGV_BREED3)
	btnOrdinaryBreed:setChecked(true)
	btnOrdinaryBreed:setOnClickScriptHandler(event_function)
	btnSpecialBreed:setOnClickScriptHandler(event_function)
	btnPetInherit:setOnClickScriptHandler(event_function)

	layoutOrdinaryBreed = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED, Tag_ui_pet_breedhouse.LAYOUT_ORDINARY_BREED)
	layoutSpecialBreed = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED, Tag_ui_pet_breedhouse.LAYOUT_SPECIAL_BREED)
	layoutPetInHerit = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED, Tag_ui_pet_breedhouse.LAYOUT_PETINHERIT)

	self:EventFunction()
	self:petOrdinaryBreed()

	local labTalk = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_NPC_TALK)
	labTalk:setVisible(false)
	local labSpecial = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_SPECIAL_TALK)
	labSpecial:setVisible(false)
	local labInherit = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_INHERIT_TALK)
	labInherit:setVisible(false)
	local imgPeople = __instance:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.IMG_BREEDNPC)
	local lab = self:getControl(Tag_ui_pet_breedhouse.PANEL_BREED,Tag_ui_pet_breedhouse.LAB_INIT_TALK)
	lab:setString("")
	NpcTalkManager.initTalk(lab,NpcTalkManager.SCENE.NormalBreed)
	NpcTalkManager.setNPCTouch(__instance,imgPeople,lab,NpcTalkManager.SCENE.NormalBreed)

	local labLuckNum = layoutOrdinaryBreed:getChildByTag(Tag_ui_pet_breedhouse.LAB_LUCK_NUM)
	local function event_load_luck_num(result) 
		labLuckNum:setString(result["lucknum"])
	end
	NetManager.sendCmd("loadbreedlucknum", event_load_luck_num)
	TouchEffect.addTouchEffect(self)

	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			-- local petContent = ItemManager.getItemsByType(1)
			-- local inheritPet = {}
			-- local breedGuide = false
			-- for i,v in ipairs(petContent) do
			-- 	if v:get("level") >= 20 then
			-- 		table.insert(inheritPet,v)
			-- 	end
			-- 	if #inheritPet >= 1 then
			-- 		for j,k in ipairs(inheritPet) do
			-- 			if v:get("mid")==k:get("mid") and v:get("level")~=k:get("level") then
			-- 				breedGuide = true
			-- 			end
			-- 		end  
			-- 	end
			-- end
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED) == false and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREEDHOUSE) == true then
				Utils.dispatchCustomEvent("event_breed",{view = "PetBreedHouse",phase = GuideManager.FUNC_GUIDE_PHASES.BREED,scene = self})
			elseif breedGuide and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.INHERIT) == false then
			
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)

end