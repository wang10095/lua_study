require "view/tagMap/Tag_ui_pet_list"

PetListUI = class("PetListUI",function()
	return TuiBase:create()
end)

PetListUI.__index = PetListUI
local __instance = nil
local gvCotent = {}

function PetListUI:create()
	local ret = PetListUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetListUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetListUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_list.PANEL_PET_LIST then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_adapt_gvactive(p_convertview, idx)
	local newPetsTable = PetAttributeDataProxy:getInstance().newPetsTable --新的宠物
	local pCell = p_convertview
	-- if pCell == nil then
		pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_pet_list", PATH_UI_PET_LIST)
		local layoutPetList = pCell:getChildByTag(Tag_ui_pet_list.LAYOUT_PET_LIST)
		-- layoutPetList:retain()
		local layoutPet = layoutPetList:getChildByTag(Tag_ui_pet_list.LAYOUT_PET)
		-- print(gvCotent[idx+1]:get("mid").."----------"..gvCotent[idx+1]:get("form"))
		local petFormConfig = ConfigManager.getPetFormConfig(gvCotent[idx+1]:get("mid"), gvCotent[idx+1]:get("form"))
		local petImg = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petFormConfig.model)
		Utils.addCellToParent(petImg,layoutPet,true)
		local noMove  = true
		local xx,yy = nil
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(false)
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = gvActive:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local size = layoutPetList:getContentSize()
			local location  = layoutPetList:convertTouchToNodeSpace(touch)
			local winSize = cc.Director:getInstance():getWinSize()
			local addYY = (1024 - winSize.height)/2
			if  size and yy>60+addYY and location.x >0 and location.x < size.width and location.y > 0 and location.y < size.height and  PetAttributeDataProxy:getInstance():get("isPopup")==false then
				layoutPetList:setScale(0.9)
				return true
			end
		 end,cc.Handler.EVENT_TOUCH_BEGAN)   
		listener:registerScriptHandler(function(touch,event)
			local location = gvActive:convertTouchToNodeSpace(touch)
			local distanceX,distanceY = math.floor(location.x-xx),math.floor(location.y-yy)
			if not (math.abs(distanceX) < 30 and math.abs(distanceY) < 30) then
				noMove = false
				layoutPetList:setScale(1.0)
			end
		end,cc.Handler.EVENT_TOUCH_MOVED )
		listener:registerScriptHandler(function()
			if noMove == true  and PetAttributeDataProxy:getInstance():get("isPopup")==false then
				ItemManager.currentPet = gvCotent[idx + 1]
				Utils.replaceScene("PetAttributeUI", __instance)
			end
			layoutPetList:setScale(1.0)
			noMove = true
		 end,cc.Handler.EVENT_TOUCH_ENDED)  
		local eventDispatcher = layoutPetList:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layoutPetList)

		local imgPetBg = layoutPetList:getChildByTag(Tag_ui_pet_list.IMG_PETLIST_BG)
		PromtManager.addRedSpot(imgPetBg,3,"UP_SKILL_LEVEL",gvCotent[idx+1]:get("id")) --添加红点监听	
		PromtManager.addRedSpot(imgPetBg,3,"TRAIN",gvCotent[idx+1]:get("id")) --添加红点监听	
		PromtManager.addRedSpot(imgPetBg,3,"UPSTAR",gvCotent[idx+1]:get("id")) --添加红点监听	
		imgPetBg:setSpriteFrame("ui_pet_list/img_petlist_bg" .. gvCotent[idx+1]:get("aptitude") .. ".png")
		local labName = layoutPetList:getChildByTag(Tag_ui_pet_list.LAB_PET_NAME)
		labName:setString(TextManager.getPetName(gvCotent[idx+1]:get("mid"),gvCotent[idx+1]:get("form")))

		local petRank = layoutPetList:getChildByTag(Tag_ui_pet_list.LAB_PET_RANK)
		petRank:setString(gvCotent[idx+1]:get("rank") .. "段")

		local petCharacter = layoutPetList:getChildByTag(Tag_ui_pet_list.LAB_PET_CHARACTER)
		local character = TextManager.getPetCharacterName(gvCotent[idx+1]:get("character"))
		petCharacter:setString(character)

		local maxStar = ConfigManager.getPetCommonConfig('star_limit')
		for i = gvCotent[idx+1]:get("star")+1,maxStar do
			local star = layoutPetList:getChildByTag(Tag_ui_pet_list["IMG_STAR"..i])
			star:setVisible(false)
		end

		local petNew = layoutPetList:getChildByTag(Tag_ui_pet_list.LAYOUT_NEW)
		petNew:setVisible(false)
		for i,v in ipairs(newPetsTable) do
			if v == gvCotent[idx+1]:get("id") then
				petNew:setVisible(true) 
			end
		end
		Spine.addSpine(petNew,"pet_attribute","new","part1",true)

		local petLevel = layoutPetList:getChildByTag(Tag_ui_pet_list.LAB_PET_LEVEL_NUM)
		local level = gvCotent[idx+1]:get("level")
		petLevel:setString(level)
	-- end
	return pCell
end

local function event_back_main_scene()
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.replaceScene("MainUI",__instance)
end

function PetListUI:onLoadScene()
	local newPetsTable = PetAttributeDataProxy:getInstance().newPetsTable --新的宠物
	for i = #newPetsTable ,1 ,-1 do
		if  newPetsTable[i]== 0 then
			table.remove(newPetsTable,i)
		end
	end

	PetAttributeDataProxy:getInstance():set("sift",0)--重置筛选
	TuiManager:getInstance():parseScene(self,"panel_pet_list",PATH_UI_PET_LIST)
  	local layout_buttom = self:getControl(Tag_ui_pet_list.PANEL_PET_LIST, Tag_ui_pet_list.LAYOUT_BUTTOM)
    Utils.floatToBottom(layout_buttom)
	local layoutTop = self:getControl(Tag_ui_pet_list.PANEL_PET_LIST,Tag_ui_pet_list.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)

	local imgPeople = layoutTop:getChildByTag(Tag_ui_pet_list.IMG_PEOPLE)
	-- imgPeople:retain()
	
	local labTalk = layoutTop:getChildByTag(Tag_ui_pet_list.LAB_TALK)
	-- labTalk:retain()
	labTalk:setString("")
	labTalk:setVerticalAlignment(1)
	NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.Pokemon)
	NpcTalkManager.setNPCTouch(self,imgPeople,labTalk,NpcTalkManager.SCENE.Pokemon)

	gvActive = self:getControl(Tag_ui_pet_list.PANEL_PET_LIST,Tag_ui_pet_list.GV_ACTIVE)
    local gvCotentPets = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
    gvCotent = {}
    local contentPet = {}
    for i,v in ipairs(gvCotentPets) do
    	if v:get("id")~=nil  then
    		table.insert(contentPet, v)
    	end
    end
    local temporaryTable = {} --暂时存储新获得的宠物
   
    for i = #contentPet ,1,-1 do
    	for j,v in ipairs(newPetsTable) do
    		if contentPet[i]:get("id") == v then
    			table.insert(temporaryTable,contentPet[i])
    		end
    	end
    end
    for i,v in ipairs(newPetsTable) do
    	for j=#contentPet ,1 , -1 do
    		if v == contentPet[j]:get("id")  then
    			table.remove(contentPet,j)
    		end
    	end
    end

    local sequence = Utils.userDefaultGet("sequence")
    if sequence == "" then
	    table.sort(temporaryTable, function(a,b)
	     	if a:get("level") == b:get("level") then
				if a:get("rank") == b:get("rank") then
					return a:get("star") > b:get("star")
				else
					return a:get("rank") > b:get("rank")	
				end
			else
				return a:get("level") > b:get("level")
			end
	    end)
		table.sort(contentPet, function(a,b) 
			if a:get("level") == b:get("level") then
				if a:get("rank") == b:get("rank") then
					return a:get("star") > b:get("star")
				else
					return a:get("rank") > b:get("rank")	
				end
			else
				return a:get("level") > b:get("level")
			end
		end)
    else
		table.sort(temporaryTable,function(a,b)
			if sequence == "aptitude" then
				local apitA = a:get("attributeGrowths")[1]+a:get("attributeGrowths")[2]
				local apitB = b:get("attributeGrowths")[1]+b:get("attributeGrowths")[2]
				if a:get(sequence) == b:get(sequence) then
					return apitA > apitB
				else
					return a:get(sequence) > b:get(sequence)
				end
			else
				return a:get(sequence) > b:get(sequence)
			end
		end)

		table.sort(contentPet,function(a,b)
			if sequence == "aptitude" then
				local apitA = a:get("attributeGrowths")[1]+a:get("attributeGrowths")[2]
				local apitB = b:get("attributeGrowths")[1]+b:get("attributeGrowths")[2]
				if a:get(sequence) == b:get(sequence) then
					return apitA > apitB
				else
					return a:get(sequence) > b:get(sequence)
				end
			else
				return a:get(sequence) > b:get(sequence)
			end
		end)
    end
    if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false then
    	for i,v in ipairs(contentPet) do --再存储等级排列后的宠物
			table.insert(gvCotent,v)
		end
    	for i,v in ipairs(temporaryTable) do --先存储新获得宠物
			table.insert(gvCotent,v)
		end
	else
		for i,v in ipairs(temporaryTable) do --先存储新获得宠物
			table.insert(gvCotent,v)
		end
		for i,v in ipairs(contentPet) do --再存储等级排列后的宠物
			table.insert(gvCotent,v)
		end
    end
    gvActive:setCountOfCell(#gvCotent) 
	gvActive:setDataSourceAdapterScriptHandler(event_adapt_gvactive)
	gvActive:reloadData()

    local function event_pet_sift()
    	local function confirmHandler()
			local gvSiftCotent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
    		local condition = PetAttributeDataProxy:getInstance():get("sift")
    		gvCotent = {}
    		for i,v in ipairs(gvSiftCotent) do
    			if v:get("id")~=nil then
    				if tonumber(v:get("aptitude")) == tonumber(condition) then
    					table.insert(gvCotent,v)
    				end
    			end
    		end
    		
    		if tonumber(condition) == 0 then
    			for i,v in ipairs(gvSiftCotent) do
			    	if v:get("id")~=nil then
    					table.insert(gvCotent, v)
    				end
    			end
    		end
    		gvActive:setCountOfCell(#gvCotent) 
			gvActive:setDataSourceAdapterScriptHandler(event_adapt_gvactive)
			gvActive:reloadData()
    	end
		NormalDataProxy:getInstance().confirmHandler = confirmHandler
		Utils.runUIScene("SiftPetPopup")
	end
  	
    local function event_pet_sequence()
		local function confirmHandler()
       		local gvCotentPets = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
       		gvCotent = {}
       		for i,v in ipairs(gvCotentPets) do
       			if v:get("id")~=nil then
    				table.insert(gvCotent, v)
    			end
       		end
       		local condition = PetAttributeDataProxy:getInstance():get("sequence")
		  	Utils.userDefaultSet("sequence", condition)
			table.sort(gvCotent,function(a,b)
				if condition == "aptitude" then
					local apitA = a:get("attributeGrowths")[1]+a:get("attributeGrowths")[2]
					local apitB = b:get("attributeGrowths")[1]+b:get("attributeGrowths")[2]
					if a:get(condition) == b:get(condition) then
						return apitA > apitB
					else
						return a:get(condition) > b:get(condition)
					end
				else
					return a:get(condition) > b:get(condition)
				end
			end)
		    local petNum = layout_buttom:getChildByTag(Tag_ui_pet_list.LAB_PETS_NUM)
		    petNum:setString(#gvCotent)
      		gvActive:setCountOfCell(#gvCotent) 
			gvActive:setDataSourceAdapterScriptHandler(event_adapt_gvactive)
			gvActive:reloadData()
		end
		NormalDataProxy:getInstance().confirmHandler = confirmHandler
		Utils.runUIScene("SequencePetPopup")
	end

    local btnBack = layout_buttom:getChildByTag(Tag_ui_pet_list.BTN_BACK)
    btnBack:setOnClickScriptHandler(event_back_main_scene)

    -- local labSift = layout_buttom:getChildByTag(Tag_ui_pet_list.LAB_SIFT)
    -- labSift:setVisible(false)
    -- btnSift:setOnClickScriptHandler(event_pet_sift)
    local btnSequence = layout_buttom:getChildByTag(Tag_ui_pet_list.BTN_SEQUENCE)
    btnSequence:setOnClickScriptHandler(event_pet_sequence)

    local petNum = layout_buttom:getChildByTag(Tag_ui_pet_list.LAB_PETS_NUM)
    petNum:setString(#gvCotent)
	PetAttributeDataProxy:getInstance().newPetsTable = {} --清空所有新获得的宠物
    local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN) and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PETLIST) == false then
				Utils.dispatchCustomEvent("event_train",{view = "PetListUI",phase = GuideManager.FUNC_GUIDE_PHASES.PETLIST,scene = self})
			end
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false and Player.getInstance():get("level") >= ConfigManager.getPetCommonConfig('skill_openlevel') then
				Utils.dispatchCustomEvent("event_upskill",{view = "PetListUI",phase = GuideManager.FUNC_GUIDE_PHASES.PET_SKILL_LIST,scene = self})
			end
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL) == false and Player.getInstance():get("level") >= 8 then
				Utils.dispatchCustomEvent("event_pet_level",{view = "PetListUI",phase = GuideManager.FUNC_GUIDE_EXTRA.PET_LIST,scene = self})
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end 

