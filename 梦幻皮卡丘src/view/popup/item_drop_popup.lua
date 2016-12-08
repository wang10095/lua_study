require "view/tagMap/Tag_popup_item_drop"

ItemDropPopup = class("ItemDropPopup",function()
	return Popup:create()
end)

ItemDropPopup.__index = ItemDropPopup
local __instance = nil
local currentItem = nil

function ItemDropPopup:create()
	local ret = ItemDropPopup.new()
	__instance = ret
	if ItemManager.currentItem ~= nil then
		currentItem = ItemManager.currentItem 
		ItemManager.currentItem = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ItemDropPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ItemDropPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_item_drop.PANEL_ITEM_DROP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

function ItemDropPopup:onLoadScene()
	eliteTable = {}
	local item,needAmount = currentItem[1],currentItem[2]
	local stageInfoTable = {} --存储信息
	if item:get("item_type") == Constants.ITEM_TYPE.TRAIN_MATERIAL  then --训练材料
		local itemConfig = ConfigManager.getItemConfig(item:get("item_type"),item:get("mid"))
		stageInfoTable = itemConfig.drop_stage
	elseif item:get("item_type") == Constants.ITEM_TYPE.EVOLUTION_STONE then
		local itemConfig = ConfigManager.getItemConfig(item:get("item_type"),item:get("mid"))
		stageInfoTable = itemConfig.drop_stage
	end

	TuiManager:getInstance():parseScene(self,"panel_item_drop",PATH_POPUP_ITEM_DROP)
	local btnClose = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.BTN_CLOSE_DROP)
	btnClose:setOnClickScriptHandler(event_close)

	layoutItem = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.LAYOUT_ITEM_PORTRAIT)
	-- local cell = TextureManager.createImg(TextureManager.RES_PATH.ITEM_IMAGE,item:get("item_type"),item:get("mid"))
	local itemNow = ItemManager.createItem(item:get("item_type"),item:get("mid"))
	local itemCell = ItemCell:create(item:get("item_type"),itemNow)
	Utils.addCellToParent(itemCell,layoutItem,true)

	local labItemName = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.LAB_ITEM_NAME)
	labItemName:setString(TextManager.getItemName(item:get("item_type"),item:get("mid")))
	local ownItemNum = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.LAB_ITEM_OWN_NUM)
	local evolutionStoneNum = ItemManager.getItemAmount(item:get("item_type"),item:get("mid"))
	ownItemNum:setString(evolutionStoneNum)
	local allItemNum = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.LAB_ITEM_ALL_NUM)
	if needAmount == 0 then
		allItemNum:setVisible(false)
	else
		allItemNum:setString("/" .. needAmount)
	end
	local listStage = self:getControl(Tag_popup_item_drop.PANEL_ITEM_DROP, Tag_popup_item_drop.LIST_STAGE)
	listStage:removeAllNodes()

	local count = listStage:getNodeCount()
  	while count < #stageInfoTable  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_drop", PATH_POPUP_ITEM_DROP)
		listStage:insertNodeAtLast(pCell)
		count = listStage:getNodeCount()
	end
	listStage:reloadData()

	for k = 1,#stageInfoTable do
		local node = listStage:getNodeAtIndex(k-1)   
		local layoutDrop = node:getChildByTag(Tag_popup_item_drop.LAYOUT_DROP)
		local layoutStage = layoutDrop:getChildByTag(Tag_popup_item_drop.LAYOUT_STAGE_PORTRAIT)
		local img = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR,k)
		Utils.addCellToParent(img,layoutStage,true)
		local labStageName = layoutDrop:getChildByTag(Tag_popup_item_drop.LAB_STAGE_NAME)
		local stageName = TextManager.getStageText(stageInfoTable[k][1], stageInfoTable[k][2]).name
		labStageName:setString(stageName)
		local stageNum = layoutDrop:getChildByTag(Tag_popup_item_drop.LAB_STAGE_NUM)
		stageNum:setString(stageInfoTable[k][1] .. "-" .. stageInfoTable[k][2])

		local labYikaiqi = layoutDrop:getChildByTag(Tag_popup_item_drop.LAB_YIKAIQI)
		labYikaiqi:setOpacity(0)
		local stageType = layoutDrop:getChildByTag(Tag_popup_item_drop.LAB_STAGE_TYPE)
		local img_yikaiqi = layoutDrop:getChildByTag(Tag_popup_item_drop.IMG_YIKAIQI)
		local img_weikaiqi = layoutDrop:getChildByTag(Tag_popup_item_drop.IMG_WEIKAIQI)


		local currentNormalChapter = Player:getInstance():get("normalChapterId") 
		local currentNormalStage = Player:getInstance():get("normalStageId") 
		local currentEliteChapter = Player:getInstance():get("eliteChapterId") 
		local currentEliteStage = Player:getInstance():get("eliteStageId") 

		if currentNormalStage < 12 then
			currentNormalStage = currentNormalStage + 1
		else
			currentNormalChapter = currentNormalChapter + 1
			currentNormalStage = 0
		end

		if currentEliteStage < 4 then
			currentEliteStage = currentEliteStage + 1
		else
			currentEliteChapter = currentEliteChapter + 1
			currentEliteStage = 0
		end

		if item:get("item_type") == Constants.ITEM_TYPE.TRAIN_MATERIAL then
			stageType:setVisible(false)
			if stageInfoTable[k][1] < currentNormalChapter or (stageInfoTable[k][1] == currentNormalChapter and stageInfoTable[k][2] <= currentNormalStage) then
				labYikaiqi:setString("已开启")
				img_weikaiqi:setVisible(false)
			else
				labYikaiqi:setString("未开启")
				img_yikaiqi:setVisible(false)
			end
		elseif item:get("item_type") == Constants.ITEM_TYPE.EVOLUTION_STONE then
			if stageInfoTable[k][1] < currentEliteChapter or(stageInfoTable[k][1] == currentEliteChapter and stageInfoTable[k][2] <= currentEliteStage) then
				labYikaiqi:setString("已开启")
				img_weikaiqi:setVisible(false)
				local elite_nums = ConfigManager.getStageCommonConfig('elite_nums')
				stageType:setString("精英本(" .. 3 .. "/" .. elite_nums .. ")")
			else
				labYikaiqi:setString("未开启")
				img_yikaiqi:setVisible(false)
			end
		end	

		local xx,yy
		local noMove = true
		local proxy = PetAttributeDataProxy:getInstance()
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = listStage:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local location  = node:convertTouchToNodeSpace(touch)
			local size = node:getContentSize()
			if  labYikaiqi:getString() == "已开启" and proxy:get("isDrop")==false and size and location.x >0 and location.x <size.width and location.y >0 and location.y <size.height and yy >0 then
				layoutDrop:setScale(0.95)
				return true
			end
		end,cc.Handler.EVENT_TOUCH_BEGAN )   
		listener:registerScriptHandler(function(touch,event)
			local selfLocation = listStage:convertTouchToNodeSpace(touch)
			local distanceX = math.abs(math.floor(selfLocation.x - xx))
			local distanceY = math.abs(math.floor(selfLocation.y - yy))
			if distanceX > 30 or distanceY > 30 then
				noMove = false
			end
		end,cc.Handler.EVENT_TOUCH_MOVED )
		listener:registerScriptHandler(function(touch,event)
			if noMove then
				if item:get("item_type") == Constants.ITEM_TYPE.TRAIN_MATERIAL then
					StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.NORMAL) --设置副本类型  普通 
					StageRecord:getInstance():set("chapter",stageInfoTable[k][1])
					proxy:set("dropStage",stageInfoTable[k][2])
				elseif item:get("item_type") == Constants.ITEM_TYPE.EVOLUTION_STONE then
					StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.ELITE) --设置副本类型  精英
					StageRecord:getInstance():set("chapter",stageInfoTable[k][1])
					proxy:set("dropStage",stageInfoTable[k][2])
				end
 				proxy:set("isDrop",true)
				Utils.pushScene("PveUI")
				Utils.popUIScene(__instance)
			end 
			layoutDrop:setScale(1.0)
			noMove = true
		end,cc.Handler.EVENT_TOUCH_ENDED ) 
		local eventDispatcher = listStage:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener,listStage)
	end
	TouchEffect.addTouchEffect(self)
end 

