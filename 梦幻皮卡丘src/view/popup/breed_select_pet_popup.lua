require  "view/tagMap/Tag_popup_breed_select_pet"

BreedSelectPetPopup = class("BreedSelectPetPopup",function()
	return Popup:create()
end)

BreedSelectPetPopup.__index = BreedSelectPetPopup
local __instance = nil
local gvCotent = {}
function BreedSelectPetPopup:create()
	local ret = BreedSelectPetPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BreedSelectPetPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BreedSelectPetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_breed_select_pet.PANEL_SELECT_PET then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BreedSelectPetPopup:event_close()
	if PetBreedProxy:getInstance().updateInherit then
		PetBreedProxy:getInstance().updateInherit()
	end
	PetBreedProxy:getInstance().updateInherit = nil
	local proxy = NormalDataProxy:getInstance()
	if  proxy.confirmHandler  ~= nil then 
		proxy.confirmHandler()
	end
	proxy.confirmHandler = nil
	proxy.cancelHandler = nil
	Utils.popUIScene(__instance)
end

function BreedSelectPetPopup:RoleTalkAbout()
	local breedType = PetBreedProxy:getInstance():get("breedType")
	local selectPopupType = PetBreedProxy:getInstance():get("selectPopupType")
	local labRoldTalk = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LAB_CHOOSE_PET)--提示语
	if selectPopupType == 1 then
		labRoldTalk:setString("选择4个没有经过培养的神奇宝贝进行融合~")
	elseif  breedType ==  2 and selectPopupType == 2 then
		local specialLevelLimit = ConfigManager.getPetCommonConfig('spacialbreed_limit')
		labRoldTalk:setString("选择培育对象，必须高于".. specialLevelLimit .."级哦")
	elseif breedType == 2 and selectPopupType == 3 then
		labRoldTalk:setString("选择消耗材料（资质品质不能低于培育对象）")
	elseif breedType == 3 and selectPopupType == 4 then
		labRoldTalk:setString("请选择继承者")
	elseif breedType == 3 and selectPopupType == 2 then
		local inheritLevelLimit = ConfigManager.getPetCommonConfig('inherit_level_limit')
		labRoldTalk:setString("选择传承者,必须高于" .. inheritLevelLimit .. "级哦")
	end
	local  btnSure = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.BTN_SURE)
	local label = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LAB_SURE)
	if selectPopupType == 1 then
		label:setString("确定")
	else
		label:setString("关闭")
	end
	btnSure:setOnClickScriptHandler(self.event_close)
end

function BreedSelectPetPopup:SiftUnCultivatePets() --筛选没有培养的神奇宝贝
	for i = #gvCotent,1,-1  do  --未经过培养的宠物  
		if gvCotent[i]:get("level")~=1 or gvCotent[i]:get("rank")~=1 or gvCotent[i]:get("star")~=1 then
			table.remove(gvCotent,i)
		else
			local skillLevels =  gvCotent[i]:get("skillLevels")	
				for j = #skillLevels,1,-1 do
					if skillLevels[j] ~= 1 then
					table.remove(gvCotent,i)
					break
				end
			end
		end
	end
end

function BreedSelectPetPopup:SiftFullAptitude()--筛选满资质的宠物 
	for i = #gvCotent,1 ,-1 do
		if gvCotent[i]:getAptitudeNum()>=Utils.getPetMaxAptitude(gvCotent[i]:get("aptitude")) then
			table.remove(gvCotent,i)
		end
	end
end

function BreedSelectPetPopup:SiftOrdinaryBreedPets() --普通融合
	self:SiftUnCultivatePets()
	function event_sortPets(a,b)
		if a:get("isSelected") == b:get("isSelected") then
			local aaa,bbb = a:get("attributeGrowths"),b:get("attributeGrowths") --先资质后mid
			if  (aaa[1]+aaa[2]) == (bbb[1]+bbb[2])  then
				return a:get("mid")<b:get("mid")
			else
				return (aaa[1]+aaa[2]) < (bbb[1]+bbb[2]) 
			end
		else
			return a:get("isSelected") > b:get("isSelected")
		end
	end

	table.sort(gvCotent, event_sortPets)
end

function BreedSelectPetPopup:SiftSpecialBreedCultivatePet() --特殊融合培育对象 
	local specialLevelLimit = ConfigManager.getPetCommonConfig('spacialbreed_limit')
	for i = #gvCotent,1 ,-1 do
		if gvCotent[i]:get("level") <= specialLevelLimit then
			table.remove(gvCotent,i)
		end
	end
	self:SiftFullAptitude()
	local function event_sortPets(a,b)
		if a:get("level") == b:get("level") then
			if a:get("rank") == b:get("rank") then
				return a:get("star") < b:get("star")
			else
				return a:get("rank") < b:get("rank")	
			end
		else
			return a:get("level") < b:get("level")
		end
	end
	table.sort(gvCotent,event_sortPets)	
end

function BreedSelectPetPopup:SiftSpecialBreedConsumePet() --特殊融合消耗材料 
	self:SiftUnCultivatePets()
	local cultivatePet = PetBreedProxy:getInstance().petSpecialBreed[1]
	for i = #gvCotent,1 ,-1 do
		if  gvCotent[i]:get("aptitude") < cultivatePet:get("aptitude")  then
			table.remove(gvCotent,i)
		end
	end

	function event_sortPets(a,b)
		if a:get("aptitude") == b:get("aptitude") then
			local aaa,bbb = a:get("attributeGrowths"),b:get("attributeGrowths")
			return (aaa[1]+aaa[2]) < (bbb[1]+bbb[2]) 
		else 
			return a:get("aptitude") < b:get("aptitude")
		end
	end
	table.sort(gvCotent, event_sortPets)
end

function BreedSelectPetPopup:SiftInheritBreedHeirPet() --继承
	self:SiftUnCultivatePets()
	self:SiftFullAptitude()
	function event_sortPets(a,b)
		local p1 = a:get("aptitude")*100 + a:get("star") * 10 
		local p2 = b:get("aptitude")*100 + b:get("star") * 10 
		return p1 > p2 
	end
	table.sort(gvCotent, event_sortPets)
end

function BreedSelectPetPopup:SiftInheritBreedInheritPet() --传承
	local proxy = PetBreedProxy:getInstance()
	if proxy.petInherit[1] == 0 then
		TipManager.showTip("没有符合要求的神奇宝贝")
		return
	end
	local inheritLevelLimit = ConfigManager.getPetCommonConfig('inherit_level_limit')
	for i = #gvCotent,1 ,-1 do
		if gvCotent[i]:get("level") < inheritLevelLimit or  gvCotent[i]:get("mid") ~= proxy.petInherit[1]:get("mid") or gvCotent[i]:getAptitudeNum() >= proxy.petInherit[1]:getAptitudeNum()  then
			table.remove(gvCotent,i)
		end
	end

	local function event_sortPets(a,b)
		if a:get("level") == b:get("level") then
			if a:get("rank") == b:get("rank") then
				return a:get("star") < b:get("star")
			else
				return a:get("rank") < b:get("rank")	
			end
		else
			return a:get("level") < b:get("level")
		end
	end
	table.sort(gvCotent,event_sortPets)
end

function BreedSelectPetPopup:SiftDemandPets()
	local breedType = PetBreedProxy:getInstance():get("breedType")
	local selectPopupType = PetBreedProxy:getInstance():get("selectPopupType")
	local labAlert = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LAB_ALERT)
	labAlert:setVisible(false)
	labAlert:setVerticalAlignment(1)
	labAlert:setString("当前没有符合要\n求的神奇宝贝！")
	if breedType == 1 and selectPopupType == 1 then  --筛选弹出框为1的宠物列表
		self:SiftOrdinaryBreedPets()
	end
	if breedType == 2 and selectPopupType == 2 then -- 选择特殊融合培育对象
		self:SiftSpecialBreedCultivatePet()
	end

	if breedType == 2 and selectPopupType == 3 then  --选择特殊融合消耗材料
		self:SiftSpecialBreedConsumePet()
		labAlert:setString("材料的资质品级不\n能低于培育对象哦")
	end

	if breedType == 3 and selectPopupType == 4 then   --选择完美传承  继承者
		self:SiftInheritBreedHeirPet()
	end
	if breedType == 3 and selectPopupType == 2 then  --选择完美传承   传承者
		self:SiftInheritBreedInheritPet()
		labAlert:setString("当前没有符合要求的神奇宝贝\n1,同种神奇宝贝 \n2,继承者资质必须高于传承者 \n3,传承者需要达到一定等级")
		labAlert:setHorizontalAlignment(0)
	end

	if #gvCotent == 0 then  --没有符合要求的神奇宝贝
		labAlert:setVisible(true)
	end
end

function event_layout_info(node,gvCotent)
	local breedType = PetBreedProxy:getInstance():get("breedType")
	local selectPopupType = PetBreedProxy:getInstance():get("selectPopupType")
	local labPetName = node:getChildByTag(Tag_popup_breed_select_pet.LAB_PET_NAME)
	local petName = TextManager.getPetName(gvCotent:get("mid"), gvCotent:get("form"))
	labPetName:setString(petName)
	local layoutPetAptitude = node:getChildByTag(Tag_popup_breed_select_pet.LAYOUT_PET_APTITUDE)
	local imgAptitude = TextureManager.createImg(TextureManager.RES_PATH.PET_APTITUDE,gvCotent:get("aptitude"))
	Utils.addCellToParent(imgAptitude,layoutPetAptitude)
	local imgRankBg = node:getChildByTag(Tag_popup_breed_select_pet.IMG_PET_RANK_BG)
	local labRank = node:getChildByTag(Tag_popup_breed_select_pet.LAB_PET_RANK)
	labRank:setString(gvCotent:get("rank") .. "段")
	if selectPopupType == 2 then
		imgRankBg:setVisible(true)
		labRank:setVisible(true)
		layoutPetAptitude:setVisible(false)
	else
		imgRankBg:setVisible(false)
		labRank:setVisible(false)
		layoutPetAptitude:setVisible(true)
	end

	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	for i = gvCotent:get("star")+1,maxStar  do
		local petStar = node:getChildByTag(Tag_popup_breed_select_pet["IMG_STAR" .. i])
		petStar:setVisible(false)
	end
	local layoutLab1 = node:getChildByTag(Tag_popup_breed_select_pet.LAYOUT_LAB1)
	local layoutLab2 = node:getChildByTag(Tag_popup_breed_select_pet.LAYOUT_LAB2)
	local layoutLab3 = node:getChildByTag(Tag_popup_breed_select_pet.LAYOUT_LAB3)
	layoutLab1:setVisible(selectPopupType == 1 or selectPopupType == 4)
	layoutLab2:setVisible(selectPopupType == 3)
	layoutLab3:setVisible(selectPopupType == 2)

	local labLevel = layoutLab3:getChildByTag(Tag_popup_breed_select_pet.LAB_LEVEL_NUM)
	labLevel:setString(gvCotent:get("level"))
	local lab_aptitude_num2 = layoutLab3:getChildByTag(Tag_popup_breed_select_pet.LAB_APTITUDE_NUM2)
	lab_aptitude_num2:setString(gvCotent:getAptitudeNum())

	local lab_character = layoutLab1:getChildByTag(Tag_popup_breed_select_pet.LAB_CHARACTER_BREED)
	lab_character:setString(TextManager.getPetCharacterName(gvCotent:get("character")))
	local lab_aptitude_num1 = layoutLab1:getChildByTag(Tag_popup_breed_select_pet.LAB_APTITUDE_NUM1)
	lab_aptitude_num1:setString(gvCotent:getAptitudeNum())

	local labAptitude = layoutLab2:getChildByTag(Tag_popup_breed_select_pet.LAB_APTITUDE_SELECT)
	labAptitude:setString(Utils.roundingOff(gvCotent:get("attributeGrowths")[1]/100+gvCotent:get("attributeGrowths")[2]/100))
end

function BreedSelectPetPopup:onLoadScene()
	local proxy = PetBreedProxy:getInstance()
	local breedType = proxy:get("breedType")
	local selectPopupType = proxy:get("selectPopupType")

	TuiManager:getInstance():parseScene(self,"panel_select_pet",PATH_POPUP_BREED_SELECT_PET)
	self:RoleTalkAbout()
	local listPetList = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LIST_PET)
	listPetList:removeAllNodes()
	local gvCotentPet = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	gvCotent = {}
	for i,v in ipairs(gvCotentPet) do
		if v:get("id")~=nil then
			table.insert(gvCotent, v)	
		end
	end
	self:SiftDemandPets()    --筛选符合要求的宠物
	local count = listPetList:getNodeCount()
	while count > #gvCotent  do
		listPetList:removeLastNode()
		count = listPetList:getNodeCount()
	end

  	while count < #gvCotent  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_pet", PATH_POPUP_BREED_SELECT_PET)
		listPetList:insertNodeAtLast(pCell)
		count = listPetList:getNodeCount()
	end
	listPetList:reloadData()

	local count = 0  --计算已经选择的数量
	local maxCount = 4
	if  breedType == 1 and selectPopupType == 1 then 
		for i,v in ipairs(proxy.petOrdinaryBreed) do  
			if v ~= 0 then
				count = count + 1 
			end
		end
	end

	local labSelected = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LAB_SELECT)
	local labSelectedNum = self:getControl(Tag_popup_breed_select_pet.PANEL_SELECT_PET, Tag_popup_breed_select_pet.LAB_SELECT_NUM)--已经选择个数
	labSelectedNum:setString(count)
	if selectPopupType ~= 1 then
		labSelectedNum:setVisible(false)
		labSelected:setVisible(false)
	end

	if #gvCotent == 0 then
		return
	end
	
	for k = 1 ,#gvCotent do
		local node = listPetList:getNodeAtIndex(k-1)
		local layoutPetHead  = node:getChildByTag(Tag_popup_breed_select_pet.LAYOUT_PET_HEAD)
		local petCell = PetCell:create(gvCotent[k])
		Utils.addCellToParent(petCell,layoutPetHead,true)
		local imgSelect = node:getChildByTag(Tag_popup_breed_select_pet.IMG_SELECT)
		imgSelect:setVisible(false)  
		--筛选选中宠物
		local selected = false --设定当前宠物没有被选中
		local breedList
		if  breedType == 1 and  selectPopupType == 1 then
			breedList =  proxy.petOrdinaryBreed
		elseif breedType == 2 and selectPopupType == 2 then
			breedList = {proxy.petSpecialBreed[1]}
		elseif breedType == 2 and selectPopupType == 3 then
			breedList = {proxy.petSpecialBreed[2]}
		elseif breedType == 3  and selectPopupType == 4  then
			breedList =  {proxy.petInherit[1]}
		elseif breedType == 3 and selectPopupType == 2 then
			breedList = {proxy.petInherit[2]}
		end

		for i,pet in ipairs(breedList) do
			if pet ~= 0 and pet:get("id") == gvCotent[k]:get("id") then
				imgSelect:setVisible(true)
				if breedType ~=1 then
					imgSelect:setVisible(false)
				end
				selected = true
				break
			end
		end

		--选择或取消宠物
		local function event_select_pet(pSender)
			if selected == false then  --如果没有选  则就选中
				if count >= maxCount then
		 			TipManager.showTip("选择宠物已达上限")
				else	
					imgSelect:setVisible(true)
					count = count + 1
					labSelectedNum:setString(count)
					if  breedType == 1 and  selectPopupType == 1 then
						proxy.petOrdinaryBreed[count] = gvCotent[k]
						gvCotent[k]:set("isSelected",maxCount +1- count)
					elseif breedType == 2 and selectPopupType == 2 then
						proxy.petSpecialBreed[1] = gvCotent[k]
						self:event_close()
					elseif breedType == 2 and selectPopupType == 3 then
						proxy.petSpecialBreed[2] = gvCotent[k]
						self:event_close()
					elseif breedType == 3  and selectPopupType == 4  then
						proxy.petInherit[1] = gvCotent[k]
						self:event_close()
					elseif breedType == 3 and selectPopupType == 2 then
						proxy.petInherit[2] = gvCotent[k] 
						self:event_close()
					end
					selected = true
				end
			else  
				imgSelect:setVisible(false)
				if  breedType == 1 and  selectPopupType == 1 then
					for i,v in ipairs(proxy.petOrdinaryBreed) do
						if v~=0 and v:get("id")== gvCotent[k]:get("id") then
							proxy.petOrdinaryBreed[i]:set("isSelected",0)
							proxy.petOrdinaryBreed[i] = 0
						end
					end
					for i,v in ipairs(proxy.petOrdinaryBreed) do
						if v==0 then
							table.remove(proxy.petOrdinaryBreed,i)
							proxy.petOrdinaryBreed[4]=0
						end
					end
				elseif breedType == 2 and selectPopupType == 2 then
					proxy.petSpecialBreed[1] = 0
				elseif breedType == 2 and selectPopupType == 3 then
					proxy.petSpecialBreed[2] = 0
				elseif breedType == 3  and selectPopupType == 4  then				
					proxy.petInherit[1] = 0
				elseif breedType == 3 and selectPopupType == 2 then
					proxy.petInherit[2] = 0
				end
				count = count - 1
				labSelectedNum:setString(count)
				selected = false
			end	
		end

		local xx,yy = nil,nil
		local noMoved = true
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = listPetList:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local location  = node:convertTouchToNodeSpace(touch)
			local size = node:getContentSize()

			if yy >70 and  size and location.x >0 and location.x <size.width and location.y >0 and location.y <size.height then
				return true
			else
				return false
			end
		end,cc.Handler.EVENT_TOUCH_BEGAN )   
		listener:registerScriptHandler(function(touch,event)
			local location = listPetList:convertTouchToNodeSpace(touch)
			local distance = math.floor(location.y-yy)
			if math.abs(distance) > Constants.TOUCH_SCOPE   then
				noMoved = false			
			end
		end,cc.Handler.EVENT_TOUCH_MOVED )
		listener:registerScriptHandler(function()
		  	if noMoved == true and yy>0 then
		  		event_select_pet()
		 	end
			noMoved = true
		end,cc.Handler.EVENT_TOUCH_ENDED )  
		local eventDispatcher = listPetList:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, listPetList)
		event_layout_info(node,gvCotent[k])
	end
	TouchEffect.addTouchEffect(self)

	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			self:show()
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_HRIR) == false and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED) then
				Utils.dispatchCustomEvent("event_breed",{view = "BreedSelectPetPopup",phase = GuideManager.FUNC_GUIDE_PHASES.BREED_HRIR,scene = self})
			elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_INHERIT) == false and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT) then
				Utils.dispatchCustomEvent("event_breed",{view = "BreedSelectPetPopup",phase = GuideManager.FUNC_GUIDE_PHASES.BREED_INHERIT,scene = self})
			end
		end
		if "exit"  == event then
			
		end
	end
	self:registerScriptHandler(onNodeEvent)
end




