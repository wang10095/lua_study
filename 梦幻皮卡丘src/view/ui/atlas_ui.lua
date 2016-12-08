require "view/tagMap/Tag_ui_atlas"

AtlasUI = class("AtlasUI",function()
	return TuiBase:create()
end)

AtlasUI.__index = AtlasUI
local __instance = nil
local tmpgvContent = {}

local buyItemListner = nil

function AtlasUI:create()
	local ret = AtlasUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function AtlasUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function AtlasUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_atlas.PANEL_ATLAS then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function AtlasUI:onLoadAllPet()
	local atlaslist = AtlasDataProxy.atlasList 
	local list = layoutTop:getChildByTag(Tag_ui_atlas.LIST_ATLAS)
	list:removeAllNodes()

	local mid = 1
	local form = 1

	local allPetTable = {}
	for i=1,100 do
		for j=1,5 do
			local petFormConfig = ConfigManager.getPetFormConfig(i,j)
			if petFormConfig then
				table.insert(allPetTable,{mid = i,form = j})
			else
				break
			end
		end
	end

	local amount = #allPetTable
	if self.btnTag > 1 then
		tmpgvContent = {}
		for i,v in ipairs(allPetTable) do
			local dept = ConfigManager.getPetConfig(v["mid"]).item_type
			if dept == self.btnTag - 1 then
				table.insert(tmpgvContent,v)
			end
		end
		amount = #tmpgvContent
		allPetTable = tmpgvContent
	end

	local cellHeight = 0
  	local count = list:getNodeCount()
	while count < amount  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_atlas", PATH_UI_ATLAS)
		cellHeight = pCell:getContentSize().height
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()
	list:setContentOffset(cc.p(0,-amount*cellHeight+list:getContentSize().height))
	for i=1, amount do
		local petConfig = ConfigManager.getPetFormConfig(allPetTable[i].mid,allPetTable[i].form)
		local node = list:getNodeAtIndex(i-1)
		local layoutPet = node:getChildByTag(Tag_ui_atlas.LAYOUT_ATLASLIST_PET)
		local pet = Pet:create()
		pet:set("id",1)
		pet:set("mid",allPetTable[i].mid)
		pet:set("form",allPetTable[i].form)
		pet:set("aptitude",5)
		pet:set("star",1)
		local petCell = PetCell:create(pet)
		Utils.addCellToParent(petCell,layoutPet,true)
		local itemnameLab = node:getChildByTag(Tag_ui_atlas.LAB_ATLASLIST_NAME)
		local name = TextManager.getPetName(allPetTable[i].mid,allPetTable[i].form)
		itemnameLab:setString(name)
		local lab_atlaslist_desc = node:getChildByTag(Tag_ui_atlas.LAB_ATLASLIST_DESC)
		local petDesc = TextManager.getPetDesc(allPetTable[i].mid,allPetTable[i].form)
		lab_atlaslist_desc:setString(petDesc)

		local collectImg = node:getChildByTag(Tag_ui_atlas.IMG_ATLASLIST_COLLECT)
		collectImg:setVisible(false)
		local  isCollected = false
		for k,v in ipairs(atlaslist) do
			if v["mid"] ==allPetTable[i].mid and v["form"] == allPetTable[i].form  then
				collectImg:setVisible(true)
				isCollected = true
			end
		end

		local noMove = true
		local xx,yy = nil,nil
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = self:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local cellLocation = node:convertTouchToNodeSpace(touch)
			local size = node:getContentSize()
			local winSize = cc.Director:getInstance():getWinSize()
			local addYY = (1136 - winSize.height)/2
			if size and yy >addYY  and yy < 820 and cellLocation.x>0 and cellLocation.y>0 and cellLocation.x<size.width and cellLocation.y<size.height then
				return true
			end
		end,cc.Handler.EVENT_TOUCH_BEGAN )   
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = self:convertTouchToNodeSpace(touch)
			local distanceX =   math.abs(math.floor(selfLocation.x - xx))
			local distanceY =   math.abs(math.floor(selfLocation.y - yy))
			if distanceX > 30 or distanceY >30 then
				noMove = false
			end
		end,cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = self:convertTouchToNodeSpace(touch)
			if noMove then
				AtlasDataProxy:getInstance():set("mid",allPetTable[i].mid)
				AtlasDataProxy:getInstance():set("form",allPetTable[i].form)
				AtlasDataProxy:getInstance():set("isCollected",isCollected)
				Utils.runUIScene("PetInfoPopup")
			end
			noMove = true
		end,cc.Handler.EVENT_TOUCH_ENDED )  
		local eventDispatcher = node:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
	end
end

function AtlasUI:onLoadScene()
	self.btnTag = 1
	TuiManager:getInstance():parseScene(self,"panel_atlas",PATH_UI_ATLAS)
	layoutTop = self:getControl(Tag_ui_atlas.PANEL_ATLAS,Tag_ui_atlas.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)

	local layoutBottom = self:getControl(Tag_ui_atlas.PANEL_ATLAS,Tag_ui_atlas.LAYOUT_BOTTOM)
	Utils.floatToBottom(layoutBottom)
	
	local btnReturn = layoutBottom:getChildByTag(Tag_ui_atlas.BTN_RETURN)
	btnReturn:setOnClickScriptHandler(function() 
		Utils.replaceScene("MainUI",self)
	end)
	self:onLoadAllPet()
	local layoutTgv = layoutTop:getChildByTag(Tag_ui_atlas.LAYOUT_TGV)

    local function event_screenpet(p_sender)
		local tag = p_sender:getTag()
		self.btnTag = tag
		self:onLoadAllPet()
	end
	for i=1,4 do
		local screeningTgv = layoutTgv:getChildByTag(Tag_ui_atlas["TGV_COMMON_"..i]) 
		if i == 1 then
			screeningTgv:setChecked(true)
		end
		screeningTgv:setOnClickScriptHandler(event_screenpet)
		screeningTgv:setTag(i)
	end
	
	TouchEffect.addTouchEffect(self)
end