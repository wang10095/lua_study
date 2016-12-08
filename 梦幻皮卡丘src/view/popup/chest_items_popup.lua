require "view/tagMap/Tag_popup_treasure_chest"

ChestItemsPopup = class("ChestItemsPopup",function()
	return Popup:create()
end)

ChestItemsPopup.__index = ChestItemsPopup
local __instance = nil
local width = 150

function ChestItemsPopup:create()
	local ret = ChestItemsPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChestItemsPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChestItemsPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_treasure_chest.PANEL_TREASURE_CHEST then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end

local function event_next_stage()
	if  NormalDataProxy:getInstance().confirmHandler  then
		NormalDataProxy:getInstance().confirmHandler()
	end
	NormalDataProxy:getInstance().confirmHandler = nil
end

local function event_close()
	Utils.popUIScene(__instance) 
	event_next_stage() 
end

local function callback_reward(result)
	Player:getInstance():set("badge",Player:getInstance():get("badge")+result["badget"])
	-- print("===badge==" .. Player:getInstance():get("badge"))
	Player:getInstance():set("gold",result["gold"])
	if #result["items"]~=0 then
		for i,v in ipairs(result["items"]) do
			ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
		end
	end
	if #result["pets"]~=0 then
		ItemManager.updatePets(result["pets"])
	end

	local btnArrowLeft = __instance:getControl(Tag_popup_treasure_chest.PANEL_TREASURE_CHEST, Tag_popup_treasure_chest.BTN_CHEST_LEFTARROW)
	local btnArrowRight = __instance:getControl(Tag_popup_treasure_chest.PANEL_TREASURE_CHEST,Tag_popup_treasure_chest.BTN_CHEST_RIGHTARROW)
	local scrolRewards = __instance:getControl(Tag_popup_treasure_chest.PANEL_TREASURE_CHEST, Tag_popup_treasure_chest.SCROL_REWARDS)
	-- scrolRewards:retain()
	local layer = scrolRewards:getContainer()

	local count = 2 + #result["items"] + #result["pets"]

	local  isScrol = true
	if count<=3 then
		scrolRewards:setDragable(false)
		btnArrowLeft:setVisible(false)
        btnArrowRight:setVisible(false)
        isScrol = false
	end
	for i=1,count do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_chest_item", PATH_POPUP_TREASURE_CHEST)
		local layoutItem = pCell:getChildByTag(Tag_popup_treasure_chest.LAYOUT_CHEST_ITEM)
		local itemName = pCell:getChildByTag(Tag_popup_treasure_chest.LAB_ITEM_NAME)
		if i == 1 then  --徽章
			local badget = TextureManager.createImg("item/img_medal.jpg")
			Utils.addCellToParent(badget,layoutItem,true)
			local border = TextureManager.createImg("cell_item/img_border_4.png")
			Utils.addCellToParent(border,badget,true)
			itemName:setString("徽章x" .. result["badget"])
		elseif i == 2 then -- 金币
			local gold = TextureManager.createImg("item/img_gold.jpg")
			Utils.addCellToParent(gold,layoutItem,true)
			local border = TextureManager.createImg("cell_item/img_border_4.png")
			Utils.addCellToParent(border,gold,true)
			itemName:setString("金币x" .. result["gold"])
		elseif i>2 and i <= 2+#result["items"] then --物品
			local item = ItemManager.createItem(result["items"][i-2]["item_type"], result["items"][i-2]["mid"])
			local itemCell = ItemCell:create(result["items"][i-2]["item_type"],item)
			Utils.addCellToParent(itemCell,layoutItem,true)
			local name = TextManager.getItemName(result["items"][i-2]["item_type"], result["items"][i-2]["mid"])
			itemName:setString(name .. "x" .. result["items"][i-2]["amount"])
			Utils.showItemInfoTips(layoutItem, item)
		else  -- 宠物 
			local petFormConfig = ConfigManager.getPetFormConfig(result["pets"][i-2-#result["items"]]["mid"], result["pets"][i-2-#result["items"]]["form"])
			local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR,petFormConfig.model)
			Utils.addCellToParent(pet,layoutItem,true)
			local border = TextureManager.createImg("cell_item/img_border_4.png")
			Utils.addCellToParent(border,pet,true)
			local petName = TextManager.getPetName(result["pets"][i-2-#result["items"]]["mid"], result["pets"][i-2-#result["items"]]["form"])
			itemName:setString(petName)
			Utils.showPetInfoTips(layoutItem,result["pets"][i-2-#result["items"]]["mid"],result["pets"][i-2-#result["items"]]["form"])
			local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			local newPet = true
		    for k,v in ipairs(petsTable) do
		    	if v:get("mid")==result["pets"][1]["mid"]  then
		    		newPet = false
		    	end
		    end
		    if newPet == true then
    			WildDataProxy:getInstance():set("newPet_mid",pet:get("mid"))
				WildDataProxy:getInstance():set("newPet_form",pet:get("form"))
		    	Utils.runUIScene("NewPetPopup")
		    	newPet = false
		    end
		end
		pCell:setAnchorPoint(cc.p(0,0))
		pCell:setPosition(cc.p((i-1)*width,0))
		layer:addChild(pCell)
	end

	scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		local xx  = scrolRewards:getContentOffset().x
        if xx>0-5 then
        	if isScrol then
        		btnArrowLeft:setVisible(false)
        		btnArrowRight:setVisible(true)
        	end
        	if xx>0 then
        		scrolRewards:setContentOffset(cc.p(0,0))
        	end
        elseif xx< -(width*(count-3))+5 then
        	if isScrol then
        	    btnArrowLeft:setVisible(true)
        		btnArrowRight:setVisible(false)
        	end
        	if xx< -(width*(count-3)) then
	        	scrolRewards:setContentOffset(cc.p(-(width*(count-3)),0))
        	end
        else
        	btnArrowLeft:setVisible(true)
        	btnArrowRight:setVisible(true)
        end
	end, 0.02, false)

	btnArrowLeft:setOnClickScriptHandler(function()
		local xx = scrolRewards:getContentOffset().x
		if math.abs(math.floor(xx))%width == 0 then
			scrolRewards:setContentOffsetInDuration(cc.p(xx+width,0),0.3)
		end
	end)

	btnArrowRight:setOnClickScriptHandler(function()
		local xx = scrolRewards:getContentOffset().x
		if math.abs(math.floor(xx))%width == 0 then
			scrolRewards:setContentOffsetInDuration(cc.p(xx-width,0),0.3)
		end
	end)

	local beganX = nil
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch,event)
		local xx = scrolRewards:getContentOffset().x
		beganX = xx
		local location = scrolRewards:convertTouchToNodeSpace(touch)
		if location.x>0 and location.y>0 and location.x<scrolRewards:getContentSize().width and location.y<scrolRewards:getContentSize().height then
			return true
		else
			return false
		end
	end,cc.Handler.EVENT_TOUCH_BEGAN )   
	listener:registerScriptHandler(function(touch,event)
		local xx = scrolRewards:getContentOffset().x
		local count = math.floor(math.abs(math.floor(xx))/width)
		local distance = math.abs(math.floor(xx))%width
		if distance ~=0  then
			if xx > beganX  then
				if distance/width>0.5 then
					scrolRewards:setContentOffsetInDuration(cc.p(-(width*(count+1)),0),0.3)	
				else
					scrolRewards:setContentOffsetInDuration(cc.p(-(width*count),0),0.3)
				end
			else
				if distance/width>0.5 then
					scrolRewards:setContentOffsetInDuration(cc.p(-(width*(count+1)),0),0.3)
				else
					scrolRewards:setContentOffsetInDuration(cc.p(-(width*count),0),0.3)
				end
			end
		end
	end,cc.Handler.EVENT_TOUCH_ENDED) 
	local eventDispatcher = scrolRewards:getEventDispatcher() -- 时间派发器 
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scrolRewards)
end

function ChestItemsPopup:onLoadScene() 	
	TuiManager:getInstance():parseScene(self,"panel_treasure_chest",PATH_POPUP_TREASURE_CHEST)
	local btnClose = self:getControl(Tag_popup_treasure_chest.PANEL_TREASURE_CHEST, Tag_popup_treasure_chest.BTN_CLOSE_CHEST)
	btnClose:setOnClickScriptHandler(event_close)

	local function onTouchNode(event)
		if event == "enter" then
			self:show()
			MusicManager.battle_victory()
			MusicManager.subMusicVolume(1)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function( )
				MusicManager.addMusicVolume(1)
			end)))
			NetManager.sendCmd("getactivity3reward",callback_reward)
			-- __instance:setAnchorPoint(cc.p(0.5,0.5))
			-- local winSize = cc.Director:getInstance():getVisibleSize()
			-- __instance:setPosition(cc.p(winSize.width/2,winSize.height/2+50))
			-- __instance:setScale(0.1)
			-- local scaleEnter  = cc.ScaleTo:create(0.2,1.0)
			-- __instance:runAction(scaleEnter)
		end
		if event == "exit" then
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
			end
		end
	end
	self:registerScriptHandler(onTouchNode)
end





